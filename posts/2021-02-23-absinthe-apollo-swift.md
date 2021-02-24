---
title: Absinthe and Apollo in Swift
layout: article
date: 2021-02-23
preview: Apollo in Swift, Absinthe in Elixir, sending GraphQL over websockets.
category: Reflection
---

[Absinthe](https://github.com/absinthe-graphql/absinthe) is a GraphQL server for the Elixir language, which interacts nicely with the [Phoenix](https://phoenixframework.org/) web framework to serve GraphQL queries over HTTP and websockets. I've used Absinthe in my paid work, and recently started using it for a side project where subscriptions will be very helpful. If you aren't familiar, GraphQL subscriptions allow you to ask the server to send updates when certain things happen, rather than repeatedly asking for updates.

This time, however, the consumer of the API isn't a JavaScript web app, but a native application written in Swift. So the full stack is:

* Absinthe, the GraphQL server
* Phoenix channels, an abstraction on top of websockets
* Websockets, the transport mechanism
* Swift application, the client

Apollo — a project that provides a GraphQL client (and server) for JavaScript — has a [client library](https://github.com/apollographql/apollo-ios) for Swift applications. Unfortunately, it doesn't work out of the box with Phoenix channels. Channels need to be joined, and Absinthe uses channels to communicate subscription data in a particular way. For JavaScript clients, the Absinthe folks provide [a library](https://github.com/absinthe-graphql/absinthe-socket) that adapts Apollo's communication to work with Absinthe over Channels. However, no such thing exists for the Swift client.

So I decided [to make one](https://github.com/aj-foster/absinthe-socket-transport).

## Introducing Absinthe Socket Transport

The Apollo client for Swift, much like the JavaScript client, has a pluggable transport system. Without changing your query-related code, you can send operations over HTTP or websockets (or a mixture of the two) just by switching which `NetworkTransport` you use when initializing the client. There are two base transports available out of the box: an HTTP transport, and an Apollo-compatible websocket transport.

To make this work, we need a new `NetworkTransport` implementation that would operate on a Phoenix channel. There's only one problem: I'm not an expert at Swift. Still, challenge accepted.

My first solution is based on what was already available:

* Apollo's `WebSocketTransport` class that implements the `NetworkTransport` protocol
* The `SwiftPhoenixClient` [library](https://github.com/davidstump/SwiftPhoenixClient) that implements communication over Phoenix channels

Development started with putting the Apollo class and its dependencies on one side of the screen, and slowly rewriting it on the other side of the screen using `SwiftPhoenixClient`. Along the way, I learned a lot about how Absinthe and Phoenix communicate.

### Welcome to Object-oriented Land (again)

Frankly, it had been a while since writing object-oriented code. Elixir's functional nature has spoiled me recently, and we use exclusively functional components when working in React at work. Getting back into the groove took some careful thought.

Realizing that the `NetworkTransport` protocol involves implementing a single function `send` was simple enough. I **really** like that protocols can be implemented via extensions in Swift, so instead of...

```swift
public class AbsintheSocketTransport: NetworkTransport {
  // Everything for the class
  // Then implement send()
}
```

We can have...

```swift
public class AbsintheSocketTransport {
  // Everything for the class
}

extension AbsintheSocketTransport: NetworkTransport {
  // Implement send()
}
```

The extension can use private functions on the class, too. Although the first release fo the package has rather messy code in the extension, I'm really glad that it could be separated out.

Getting back to chaining methods instead of piping functions was an adjustment, but luckily the `SwiftPhoenixClient` makes it easy with its return values. There is a nice consistency between having a function return a modified version of its first argument and having a method return the original object.

### Welcome to Thread Land (again)

The isolated processes in the Erlang runtime are really nice. Having data always copied between processes, and not having to worry about _retain cycles_, means I had a mental adjustment to make.

`SwiftPhoenixLibrary` offers two variants of many of its methods: one where you manage your own retain cycles, and one where they manage it for you. The existence of these options was important to remind me to be careful. I found it nice to begin with the "we'll do it for you" variants and transition to the self-managed ones as time went on. There's probably something wrong with my implementation, but it's a start.

I'll always wonder about the self-talk implications of typing `[weak self]` so much.

### Creating a Swift Package

It seems like there are several ways to manage packages in Swift. I'm unfamiliar with the community trends, but it seems like _Swift Package Manager_ is the newest and most well-supported within Xcode. The documentation for creating a package is friendly enough, but it took some trial and error to get the main manifest right. Hopefully it isn't offensive not to immediately support the other package managers.

Using the package locally was not altogether fun. Xcode and Swift Package Manager support referencing a local copy of the package, but you still have to commit and refresh the dependency to use any changes. Luckily most of the code was originally written within the project where it was needed before creating a separate package. In the future I would love to investigate this more.

Also, the package doesn't have any tests. That's a lesson for another day.

## Broader Perspective

Elixir as a language is basically complete, according to its creator. I would agree; the fact that he was recently able to bring Elixir to the realm of high-performance [numerical computing](https://github.com/elixir-nx/nx) using a **library** rather than modifications to the core language is a huge testament to its extensibility.

So what's left to build? Stuff like this. We've laid the groundwork for an incredible platform, and now it's time to go back and fill in the little holes. How Elixir and its widely-adopted libraries interact with other languages is a great place to focus.

I don't expect anyone to use [Absinthe Socket Transport](https://github.com/aj-foster/absinthe-socket-transport), but it's there if you need it.
