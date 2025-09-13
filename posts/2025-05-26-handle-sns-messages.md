---
title: Handling AWS SNS Messages in Elixir
layout: article
date: 2025-05-26
preview: An example of handling Amazon Web Services Simple Notification Service messages in an Elixir / Phoenix application.
category: Guide
---

I recently wanted to accept messages from an Amazon Web Services [Simple Notification Service](https://docs.aws.amazon.com/sns/latest/dg/welcome.html) topic in an Elixir / Phoenix application.
An [HTTPS endpoint](https://docs.aws.amazon.com/sns/latest/dg/sns-http-https-endpoint-as-subscriber.html) is just one way to subscribe to messages on a topic, but it's the most relevant if you already have a web service running.
It took a bit of work — and the documentation led me astray for a while — so here's a summary of the process.

## SNS Setup

We aren't going to focus on the full setup of the SNS topic, but there is one very important setting you'll need to adjust.

By default, SNS sends messages with `Content-Type: text/plain; charset=UTF-8`.
As a result, you must either:

1. Manually decode the request body as JSON, or
2. Tell the SNS topic to send messages with the correct content type.

The following Delivery Policy sets the content type while leaving all other settings at their default values:

```json
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "numRetries": 3,
      "numNoDelayRetries": null,
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numMinDelayRetries": null,
      "numMaxDelayRetries": null,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultRequestPolicy": {
      "headerContentType": "application/json"
    }
  }
}
```

Without taking one of these steps, the incoming connection struct will have empty `body_params`.

## Routing

First we need to create the route for accepting the messages.
They will be HTTP POST requests at a path of your choosing.
I prefer to group webhook-like requests in a `/hook` scope with routes describing their source:

```elixir
defmodule MyAppWeb.Router do
  # ...

  pipeline :hook do
    plug :accepts, ["json"]
  end

  scope "/hook", MyAppWeb do
    pipe_through :hook

    post "/sns", SNSController, :notification
  end
end
```

We want to process the incoming requests as JSON, but we don't want any of the other plugs that might be part of a typical `:api` pipeline.

**Note**: If you have experience dealing with webhooks, you may be inclined to modify the "reader" plug and ensure the original request body is preserved for verification later.
This is not necessary for verifying SNS messages.
All of the data you need comes from individual keys of the JSON body (not the raw body itself).

## Controller Action

Let's lay out a basic controller action to handle incoming messages:

```elixir
defmodule MyAppWeb.SNSController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  action_fallback :fallback

  def notification(conn, params) do
    with :ok <- verify_message(params),
         :ok <- handle_management_messages(params) do
      # Handle message here.
      send_resp(conn, :ok, "")
    end
  end

  #
  # Fallback
  #

  @doc false
  def fallback(conn, {:ignore, reason})
      when is_binary(reason),
      do: send_resp(conn, :ok, reason)

  def fallback(conn, {:error, code, reason})
      when is_atom(code) and is_binary(reason),
      do: send_resp(conn, code, reason)

  def fallback(conn, {:error, reason})
      when is_binary(reason),
      do: send_resp(conn, :internal_server_error, reason)
end
```

There's a lot going on already, so let's break it down:

1. While you can `use MyAppWeb, :controller` as is normal in a Phoenix controller, we've skipped that and directly called the `use` and `import`s we need.
2. If validating the authenticity of a message fails, we want to return an error and abort further processing.
  An `action_fallback` using a local function makes this easy while maintaining readability.
3. SNS sends two types of "management" messages, `SubscriptionConfirmation` and `UnsubscribeConfirmation`.
  Neither of these are messages that should be handled by our normal handler, so we will instead return `{:ignore, ...}` to abort processing.
4. If we successfully handle a message, an empty 200 response is perfect.

Next we'll fill in the details of `verify_message/1` and `handle_management_messages/1`.

## Verify Messages

Message verification ensures that messages come from Amazon, and not from some random person running a `curl` command in their terminal.
It **does not** tell us that the message came from the topic we expected — we still have to verify that ourselves — but it **does** tell us that the topic listed in the message is accurate.

Amazon provides [some documentation](https://docs.aws.amazon.com/sns/latest/dg/sns-verify-signature-of-message.html) about the process of verifying messages, and it's a good idea to read through it.
However, there are a few details that may be misleading when implementing it in another language.
So, let's talk through it.

```elixir
  @spec verify_message(map) :: :ok | {:error, String.t()}
  defp verify_message(message) do
    string_to_sign = construct_signed_string(message) <> "\n"

    with {:ok, key} <- get_public_key(message["SigningCertURL"]),
         {:ok, hash_algorithm} <- get_hash_algorithm(message["SignatureVersion"]),
         {:ok, decoded_signature} <- decode_signature(message["Signature"]) do
      if :public_key.verify(string_to_sign, hash_algorithm, decoded_signature, key) do
        :ok
      else
        {:error, "Signature verification failed"}
      end
    end
  end
```

To complete message verification, we will (1) construct the signed string, (2) get the public key used to sign the message, (3) determine the hash algorithm to use, (4) decode the signature, and (5) verify the signature.

### Construct Signed String

Like many popular webhook providers, SNS provides a message _signature_ to provide cryptographic proof that a message comes from Amazon and has not been tampered with.
Unlike many popular webhook providers, the signature is not based on the full raw message body, but rather a subset of message fields that are concatenated together in a particular way.
(This is because the signature itself is part of the message body, rather than a header.)

As a result, we need to construct the signed string ourselves:

```elixir
  @spec construct_signed_string(map) :: String.t()
  defp construct_signed_string(message)

  defp construct_signed_string(%{"Type" => "Notification"} = message) do
    subject = message["Subject"]

    [
      "Message",
      message["Message"],
      "MessageId",
      message["MessageId"],
      if(subject, do: "Subject"),
      if(subject, do: subject),
      "Timestamp",
      message["Timestamp"],
      "TopicArn",
      message["TopicArn"],
      "Type",
      message["Type"]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  # Catch-all: SubscriptionConfirmation and UnsubscribeConfirmation
  defp construct_signed_string(message) do
    [
      "Message",
      message["Message"],
      "MessageId",
      message["MessageId"],
      "SubscribeURL",
      message["SubscribeURL"],
      "Timestamp",
      message["Timestamp"],
      "Token",
      message["Token"],
      "TopicArn",
      message["TopicArn"],
      "Type",
      message["Type"]
    ]
    |> Enum.join("\n")
  end
```

As mentioned in [the documentation](https://docs.aws.amazon.com/sns/latest/dg/sns-verify-signature-of-message-verify-message-signature.html), we extract certain fields from the message depending on the message type.
If the subject field is empty, we omit it.

**Warning**: At the time of writing, the instructions also say "Important: Do not add a newline character at the end of the string."
This is misleading, as the binary passed to `:public_key.verify/4` must have a trailing newline in order to succeed.
However, this newline is implicitly added in their example `echo` command, so it's important not to add _an additional newline_ at the end.
I've sent in feedback on how this might be worded better.

We add a final newline to the constructed string back in `verify_message/1`.

### Get Public Key

The message signature is created using a public key provided by Amazon.
In order to verify it, we have to download and decode the key.

```elixir
  @spec get_public_key(String.t()) :: {:ok, :public_key.public_key()} | {:error, String.t()}
  defp get_public_key(signing_cert_url) do
    if key = :persistent_term.get({__MODULE__, signing_cert_url}, nil) do
      {:ok, key}
    else
      with :ok <- validate_signing_cert_url(signing_cert_url),
           {:ok, cert} <- download_signing_cert(signing_cert_url),
           {:ok, key} <- decode_signing_cert(cert) do
        :persistent_term.put({__MODULE__, signing_cert_url}, key)
        {:ok, key}
      end
    end
  end
```

Because this step requires making an external network call, it isn't something we want to repeat for every message that arrives.
We can store the results of the decoding in `persistent_term` storage (or something similar, like an ETS table) to improve performance.

The process fo downloading and decoding the certificate requires:

1. Validating the certificate URL to ensure it comes from Amazon,
2. Downloading the certificate, and 
3. Decoding the public key from the certificate file.

#### Validate Certificate URL

In order to avoid downloading and processing a potentially malicious file, we need to validate that the signing certificate URL provided in the message is trustworthy.
Valid signing certificates are hosted at `sns.[region].amazonaws.com`, so we can check the hostname against this pattern:

```elixir
  @spec validate_signing_cert_url(String.t()) :: :ok | {:error, String.t()}
  defp validate_signing_cert_url(signing_cert_url) do
    valid_hostname? =
      URI.parse(signing_cert_url).host
      |> String.match?(~r/^sns\.[a-zA-Z0-9\-]+\.amazonaws\.com$/)

    if valid_hostname? do
      :ok
    else
      {:error, "Invalid signing certificate URL"}
    end
  end
```

#### Download Signing Certificate

Downloading the certificate file is straightforward using your HTTP client of choice:

```elixir
  @spec download_signing_cert(String.t()) :: {:ok, binary} | {:error, String.t()}
  defp download_signing_cert(signing_cert_url) do
    case Req.get(signing_cert_url) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Req.Response{status: status}} when status in 400..599 ->
        {:error, "Failed to fetch signing certificate: HTTP #{status}"}

      {:error, reason} ->
        {:error, "Failed to fetch signing certificate: #{inspect(reason)}"}
    end
  end
```

#### Decode Signing Certificate

The certificate we get from Amazon has a lot of information beside the public key we need to validate the message signature.
Luckily, Erlang provides standard library functions for decoding and verifying.
Unfortunately, this process makes heavy use of Erlang records, which don't have first-class support in Elixir.

Let's begin by creating macros for the records we'll need to destructure.
This code, like all of the functions we've defined so far, goes inside the controller module.

```elixir
  require Record

  Record.defrecord(
    :otp_certificate,
    Record.extract(:OTPCertificate, from_lib: "public_key/include/public_key.hrl")
  )

  Record.defrecord(
    :otp_tbs_certificate,
    Record.extract(:OTPTBSCertificate, from_lib: "public_key/include/public_key.hrl")
  )

  Record.defrecord(
    :otp_subject_public_key_info,
    Record.extract(:OTPSubjectPublicKeyInfo, from_lib: "public_key/include/public_key.hrl")
  )
```

These records work from outside-in.
When using the `:otp` mode to decode the certificate, the information we want is inside an `OTPCertificate`, `OTPTBSCertificate`, and `OTPSubjectPublicKeyInfo` record.
In Erlang, we would access the public key using:

```erlang
Cert#'OTPCertificate'.tbsCertificate#'OTPTBSCertificate'.subjectPublicKeyInfo#'OTPSubjectPublicKeyInfo'.subjectPublicKey
```

Luckily, once we generate the helper macros, we can do this in a pipeline:

```elixir
  @spec decode_signing_cert(binary) :: {:ok, :public_key.public_key()} | {:error, String.t()}
  defp decode_signing_cert(cert) do
    :public_key.pem_decode(cert)
    |> then(&:lists.keysearch(:Certificate, 1, &1))
    |> then(fn {:value, {:Certificate, cert, :not_encrypted}} -> cert end)
    |> :public_key.pkix_decode_cert(:otp)
    |> otp_certificate(:tbsCertificate)
    |> otp_tbs_certificate(:subjectPublicKeyInfo)
    |> otp_subject_public_key_info(:subjectPublicKey)
    |> then(&{:ok, &1})
  rescue
    _ -> {:error, "Failed to decode signing certificate"}
  end
```

This function is particularly dense.
If you're curious, check out the documentation (and source!) for the Erlang `public_key:pem_decode/1` and `public_key:pkix_decode_cert/2` functions.
Reading through it gave me an appreciation for the technical details involved in asymmetric cryptography, which we sometimes take for granted.

It's slightly lazy to use a generic `rescue` in this way, but there are many different things that can go wrong during this decoding process if we are presented with a certificate that does not conform to our narrow expectations.
Rescue, and move on.

### Hash Algorithm and Signature

As if this process weren't involved enough, messages may use one of two different hashing algorithms (SHA-1 and SHA-256) depending on their `SignatureVersion`.

**Note**: It is recommended by Amazon to set the signature version of the topic to `"2"` for enhanced security.

Translating the signature version is simple, but first we have to browse through a few levels of Erlang type definitions to find the right atoms to use (starting with the spec for `public_key:verify/4`).

```elixir
  @spec get_hash_algorithm(integer) :: {:ok, :sha | :sha256} | {:error, String.t()}
  defp get_hash_algorithm("1"), do: {:ok, :sha}
  defp get_hash_algorithm("2"), do: {:ok, :sha256}
  defp get_hash_algorithm(_), do: {:error, "Unsupported signature version"}
```

Our signature needs to be decoded from base-64 before being passed to the verification:

```elixir
  @spec decode_signature(String.t()) :: {:ok, binary} | {:error, String.t()}
  defp decode_signature(signature) do
    case Base.decode64(signature) do
      {:ok, decoded_signature} -> {:ok, decoded_signature}
      :error -> {:error, "Invalid signature format"}
    end
  end
```

Now we have all of the data we need to run the verification.

### Verify the Signature

Everything we've done so far has been an elaborate preparation for a single function call:

```elixir
:public_key.verify(string_to_sign, hash_algorithm, decoded_signature, key)
```

It returns a simple `true` or `false` response for our troubles.
Calling this function is preferred because it works with several different key types without additional processing.
Erlang's `crypto:verify/5` is also available, but we would have to detect the key type and extract its data.

If the message is valid, we continue.
Otherwise, we can immediately return an error.

## Handle Management Messages

SNS has two message types, `SubscriptionConfirmation` and `UnsubscribeConfirmation`, that should not be processed by our normal message handlers.
For these, we will take any necessary action, and return `{:ignore, ...}` to escape processing early.

```elixir
  @spec handle_management_messages(map) ::
          :ok | {:ignore, String.t()} | {:error, atom, String.t()}
  defp handle_management_messages(message)

  defp handle_management_messages(%{"Type" => "UnsubscribeConfirmation"}) do
    {:ignore, "Unsubscribe confirmation; not a notification"}
  end
```

There's generally no action necessary when receiving an unsubscribe confirmation.
We have a little more work to do for subscription confirmations, however.
SNS requires subscriptions are [confirmed](https://docs.aws.amazon.com/sns/latest/dg/SendMessageToHttp.confirm.html) by clicking a link in the message.
We should only do this if the SNS topic matches one that we want to subscribe to; otherwise, someone can subscribe our application to a real SNS topic that they control.

```elixir
  defp handle_management_messages(%{"Type" => "SubscriptionConfirmation"} = message) do
    # TODO: Check if the `Topic` is one we care about.
    case Req.get(message["SubscribeURL"]) do
      {:ok, %Req.Response{status: 200}} ->
        {:ignore, "Subscription confirmation; not a notification"}

      {:ok, %Req.Response{status: status}} when status in 400..599 ->
        {:error, :bad_request, "Failed to confirm subscription: HTTP #{status}"}

      {:error, reason} ->
        {:error, :internal_server_error, "Failed to confirm subscription: #{inspect(reason)}"}
    end
  end

  defp handle_management_messages(_params), do: :ok
```

These additional clauses visit the confirmation URL, if necessary, or simply continue processing of the message for regular notifications.

## Other Considerations

Above we note that we should only perform subscription confirmations when we recognize the SNS topic.
Another way to address the issue of potentially receiving subscription confirmations from unknown topics is with HTTP Basic Auth.
SNS supports providing a username / password combination to include in message deliveries.
Meanwhile, Plug provides [`Plug.BasicAuth`](https://hexdocs.pm/plug/Plug.BasicAuth.html) to help us integrate this into our application.

**Warning**: It is recommended to use runtime confirmation for authentication secrets like this.
As a result, we need to use the indirect approach documented [here](https://hexdocs.pm/plug/Plug.BasicAuth.html#module-runtime-time-usage).

## Putting it all Together

Here's the complete module:

```elixir
defmodule MyAppWeb.SNSController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  action_fallback :fallback

  def notification(conn, params) do
    with :ok <- verify_message(params),
         :ok <- handle_management_messages(params) do
      # Handle message here.
      send_resp(conn, :ok, "")
    end
  end

  #
  # Fallback
  #

  @doc false
  def fallback(conn, {:ignore, reason})
      when is_binary(reason),
      do: send_resp(conn, :ok, reason)

  def fallback(conn, {:error, code, reason})
      when is_atom(code) and is_binary(reason),
      do: send_resp(conn, code, reason)

  def fallback(conn, {:error, reason})
      when is_binary(reason),
      do: send_resp(conn, :internal_server_error, reason)

  #
  # Verify
  #

  require Record

  Record.defrecord(
    :otp_certificate,
    Record.extract(:OTPCertificate, from_lib: "public_key/include/public_key.hrl")
  )

  Record.defrecord(
    :otp_tbs_certificate,
    Record.extract(:OTPTBSCertificate, from_lib: "public_key/include/public_key.hrl")
  )

  Record.defrecord(
    :otp_subject_public_key_info,
    Record.extract(:OTPSubjectPublicKeyInfo, from_lib: "public_key/include/public_key.hrl")
  )

  @spec verify_message(map) :: :ok | {:error, String.t()}
  defp verify_message(message) do
    string_to_sign = construct_signed_string(message) <> "\n"

    with {:ok, key} <- get_public_key(message["SigningCertURL"]),
         {:ok, hash_algorithm} <- get_hash_algorithm(message["SignatureVersion"]),
         {:ok, decoded_signature} <- decode_signature(message["Signature"]) do
      if :public_key.verify(string_to_sign, hash_algorithm, decoded_signature, key) do
        :ok
      else
        {:error, "Signature verification failed"}
      end
    end
  end

  @spec construct_signed_string(map) :: String.t()
  defp construct_signed_string(message)

  defp construct_signed_string(%{"Type" => "Notification"} = message) do
    subject = message["Subject"]

    [
      "Message",
      message["Message"],
      "MessageId",
      message["MessageId"],
      if(subject, do: "Subject"),
      if(subject, do: subject),
      "Timestamp",
      message["Timestamp"],
      "TopicArn",
      message["TopicArn"],
      "Type",
      message["Type"]
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp construct_signed_string(message) do
    [
      "Message",
      message["Message"],
      "MessageId",
      message["MessageId"],
      "SubscribeURL",
      message["SubscribeURL"],
      "Timestamp",
      message["Timestamp"],
      "Token",
      message["Token"],
      "TopicArn",
      message["TopicArn"],
      "Type",
      message["Type"]
    ]
    |> Enum.join("\n")
  end

  @spec get_public_key(String.t()) :: {:ok, :public_key.public_key()} | {:error, String.t()}
  defp get_public_key(signing_cert_url) do
    if key = :persistent_term.get({__MODULE__, signing_cert_url}, nil) do
      {:ok, key}
    else
      with :ok <- validate_signing_cert_url(signing_cert_url),
           {:ok, cert} <- download_signing_cert(signing_cert_url),
           {:ok, key} <- decode_signing_cert(cert) do
        :persistent_term.put({__MODULE__, signing_cert_url}, key)
        {:ok, key}
      end
    end
  end

  @spec validate_signing_cert_url(String.t()) :: :ok | {:error, String.t()}
  defp validate_signing_cert_url(signing_cert_url) do
    valid_hostname? =
      URI.parse(signing_cert_url).host
      |> String.match?(~r/sns\.[a-zA-z0-9\-]+\.amazonaws\.com/)

    if valid_hostname? do
      :ok
    else
      {:error, "Invalid signing certificate URL"}
    end
  end

  @spec download_signing_cert(String.t()) :: {:ok, binary} | {:error, String.t()}
  defp download_signing_cert(signing_cert_url) do
    case Req.get(signing_cert_url) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Req.Response{status: status}} when status in 400..599 ->
        {:error, "Failed to fetch signing certificate: HTTP #{status}"}

      {:error, reason} ->
        {:error, "Failed to fetch signing certificate: #{inspect(reason)}"}
    end
  end

  @spec decode_signing_cert(binary) :: {:ok, :public_key.public_key()} | {:error, String.t()}
  defp decode_signing_cert(cert) do
    :public_key.pem_decode(cert)
    |> then(&:lists.keysearch(:Certificate, 1, &1))
    |> then(fn {:value, {:Certificate, cert, :not_encrypted}} -> cert end)
    |> :public_key.pkix_decode_cert(:otp)
    |> otp_certificate(:tbsCertificate)
    |> otp_tbs_certificate(:subjectPublicKeyInfo)
    |> otp_subject_public_key_info(:subjectPublicKey)
    |> then(&{:ok, &1})
  rescue
    _ ->
      {:error, "Failed to decode signing certificate"}
  end

  @spec get_hash_algorithm(integer) :: {:ok, :sha | :sha256} | {:error, String.t()}
  defp get_hash_algorithm("1"), do: {:ok, :sha}
  defp get_hash_algorithm("2"), do: {:ok, :sha256}
  defp get_hash_algorithm(_), do: {:error, "Unsupported signature version"}

  @spec decode_signature(String.t()) :: {:ok, binary} | {:error, String.t()}
  defp decode_signature(signature) do
    case Base.decode64(signature) do
      {:ok, decoded_signature} -> {:ok, decoded_signature}
      :error -> {:error, "Invalid signature format"}
    end
  end

  #
  # Confirm Subscription
  #

  @spec handle_management_messages(map) ::
          :ok | {:ignore, String.t()} | {:error, atom, String.t()}
  defp handle_management_messages(%{"Type" => "SubscriptionConfirmation"} = message) do
    case Req.get(message["SubscribeURL"]) do
      {:ok, %Req.Response{status: 200}} ->
        {:ignore, "Subscription confirmation; not a notification"}

      {:ok, %Req.Response{status: status}} when status in 400..599 ->
        {:error, :bad_request, "Failed to confirm subscription: HTTP #{status}"}

      {:error, reason} ->
        {:error, :internal_server_error, "Failed to confirm subscription: #{inspect(reason)}"}
    end
  end

  defp handle_management_messages(%{"Type" => "UnsubscribeConfirmation"}) do
    {:ignore, "Unsubscribe confirmation; not a notification"}
  end

  defp handle_management_messages(_params), do: :ok
end

```

It's a lot of processing for this kind of webhook, but also not so much that it requires the creation of a library.
Adding logs is a good idea to help diagnose message verification failures in the future.

Remember to set the content type and signature versions on your topics.
