defmodule Site.Sass do
  @moduledoc false
  use GenServer

  def start_link(opts) do
    case Mix.env() do
      :dev ->
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)

      _ ->
        :ignore
    end
  end

  def init(_opts) do
    dir =
      File.cwd!()
      |> Path.join("styles")
      |> Path.absname()

    watcher =
      case FileSystem.start_link(dirs: [dir]) do
        {:ok, pid} -> pid
        :ignore -> nil
      end

    unless is_nil(watcher) do
      FileSystem.subscribe(watcher)
      {:ok, watcher}
    else
      {:error, :no_watch}
    end
  end

  def handle_info({:file_event, _, {path, _events}}, state) do
    case Path.extname(path) do
      ".sass" ->
        IO.puts("[Sass] Processing #{path}")
        run()

      ".scss" ->
        IO.puts("[Sass] Processing #{path}")
        run()

      _ ->
        :noop
    end

    {:noreply, state}
  end

  def handle_info({:file_event, _, _info}, state), do: {:noreply, state}

  # Ignore warning about Sass.compile_file/1; it's a NIF that dialyzer doesn't understand.
  @dialyzer {:nowarn_function, run: 0}

  def run() do
    File.cwd!()
    |> Path.join(["styles/", "*.{sass,scss}"])
    |> Path.absname()
    |> Path.wildcard()
    |> Enum.each(fn
      "_" <> _rest ->
        nil

      path ->
        file_no_extension =
          path
          |> Path.basename()
          |> Path.rootname()

        File.mkdir_p!("assets/css")

        destination =
          File.cwd!()
          |> Path.join("assets/css")
          |> Path.join(file_no_extension <> ".css")
          |> Path.absname()

        with {:ok, sass} <- Sass.compile_file(path),
             :ok <- File.write(destination, sass) do
          IO.puts("[Sass] Wrote #{destination}")
        else
          error ->
            IO.inspect(error, label: "[Sass] Error")
        end
    end)
  end
end
