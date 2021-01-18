---
title: Terminal Basics
date: 2014-10-20
preview: Notes from my talk "Exploring Terminal" for Design & Code at UCF.
category: Guide
---

In this guide, I hope to:

* Give you insight into what the terminal is, and what it can do.
* Explain the risks and rewards of using the terminal.
* Encourage you to try it out with some simple tasks.

*Note: "Terminal" in this guide refers to the UNIX-like terminal you'll find in a Mac or Linux Operating System. Although some of the functionality described here can be replicated in the Windows PowerShell, it is a fundamentally different environment. I highly encourage Windows users to check out [Cygwin](https://www.cygwin.com/), which is designed to give you a proper UNIX-like environment on Windows.*

### What is the mystical Terminal?

In short, the Terminal is a window that gives you direct access to your Operating System. Instead of using an application to pass your requests on to the OS, you can tell it what to do with simple commands.

It's a lot like the difference between going to advising and signing up for classes online. Even though an application on your computer (your advising office) can do everything you need, why wade through all of its policies and restrictions when you can tell the system (myUCF) exactly what you want and have it done immediately?

Of course, this makes the terminal dangerous. Because you are directly telling the OS what to do, there are minimal safeguards; for example: if you delete a file, it's gone forever. You can seriously mess up your system (trust me, I have). Don't let that turn you away, though; if you respect the terminal, it can be a very powerful tool.

### So, how does it work?

When you type into a terminal, it has a list of places to check for commands that match whatever you type (the [$PATH variable](http://en.wikipedia.org/wiki/PATH_%28variable%29), an advanced topic). For example, if you enter "whoami" in your terminal, it checks a few places for an executable file called "whoami". When it finds /usr/bin/whoami, it runs it, and that executable prints out your username.

By default, you have over a thousand commands you can run, with functionalities ranging from copying files to creating partitions on your hard disk. Let's take a look at some basic commands for navigating and managing your files.

When you start a new terminal session, your current location or "working directory" is your home folder, such as /home/someuser. You can run `pwd` to find out where you are, `cd` to change directories, and `ls` to list the files in your current location.

<p class="image">
    <img src="https://assets.aj-foster.com/assets/2015/term1.png" title="Navigating Filesystems" alt="Basic Filesystem Navigation in Terminal">
    <span class="tsxs">Basic Filesystem Navigation in Terminal</span>
</p>

As you can see, the commands are like small building blocks you can put together to do interesting things. Some commands have arguments associated with them: for example, `cd <location>` changes directory to the specified location. Commands might have flags as well: for example, `ls -l` gives you more information about the files in your current directory.

<p class="image">
    <img src="https://assets.aj-foster.com/assets/2015/term2.png" title="Commands with Arguments and Flags" alt="Example Commands with Arguments and Flags">
    <span class="tsxs">Example Commands with Arguments and Flags</span>
</p>

With frequent use, you will memorize most of the basic commands you need to work in the terminal. For other commands, you have Google and Manual Pages at your disposal.

If you run `man pwd`, you'll see the manual page for the `pwd` command. At the top is a short description of what it does. Further down, you can see all of the arguments, flags, and options the command might accept. For `pwd`, there are only two possible flags that change the behavior depending on how your filesystem is structured. *Note: Man pages are displayed in a terminal program called `less`. You can use the up/down arrows to scroll. To exit, press Q.*

<p class="image">
    <img src="https://assets.aj-foster.com/assets/2015/term3.png" title="Man Pages" alt="Manual Page for the pwd Command">
    <span class="tsxs">Manual Page for the pwd Command</span>
</p>

### Why should I care?

Sure, there are applications out there to do most anything you need. Many users never touch the terminal, and aren't any worse off because of it. Here are a few reasons I use the terminal on a regular basis:

* Some things are much easier in the terminal. Example: any repetitive action (such as renaming many files at once, or according to some rule). *Note: OS X Yosemite helps out with this particular example.*
* The terminal can replace entire applications. Example: with prior setup, you can use `sudo apachectl start` to replace MAMP for running a web server locally on your Mac.
* You can save money. Example: if you want to compile Sass into CSS, you could pay for CodeKit on the Mac (a fantastic investment, if you can make it), or you can install and use the `sass` command in terminal.

### How do I get started?

If you find yourself needing to do a simple task on your computer, try it out in terminal. For example, if you need to open a PDF on your Mac, try `cd`-ing to the correct directory and using `open <filename>` instead of going through Finder. Periodically ask yourself if you can replace an application with a few terminal commands. A lot of times, the answer will be "yes."

Here are some technical things to keep in mind:

* Commands and filenames are case sensitive.
* Things are different across operating systems (very different on Windows).
* The `rm` command, for deleting a file, is permanent.
* There are plenty of resources to help you out!

### What's next?

If you are interested in learning more, check out some of these advanced topics:

* [Cygwin](https://www.cygwin.com/), for getting a UNIX-like environment on Windows.
* [The $PATH variable](http://en.wikipedia.org/wiki/PATH_%28variable%29), which tells your terminal where to look for commands.
* [Changing your prompt](http://itsmetommy.com/2011/02/09/changing-your-shell-prompt/), because doing so is strangely satisfying.
* [Basics of Shell Scripting](https://supportweb.cs.bham.ac.uk/docs/tutorials/docsystem/build/tutorials/unixscripting/unixscripting.html), because shell (terminal language) scripts can do pretty much anything.

<style>
    .image {
        border: 2px solid var(--ajBorderColor);
        margin: auto;
        max-width: 40rem;
        padding: 1rem;
        text-align: center;
    }

    .image > img {
        max-width: 100%;
    }
</style>
