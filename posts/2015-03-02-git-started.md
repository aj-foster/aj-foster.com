---
title: Getting Started with Git
date: 2015-03-02
preview: Notes from my lecture for PHY 3905 in Spring 2015.
category: Guide
---

*This guide is a written / more accessible version of a lecture prepared for PHY 3905, a prototype class for introducing scientific computing. In context, the lecture provides a glimpse at Git and its uses to students who have recently been introduced to programming with Python, the Terminal, and basic shell tasks.*

In this guide, I hope to:

* Give you insight into what the Git is, and what it can do.
* Make an argument for using Git in your projects.
* Explain the basics of using Git.
* Hint to the depth of functionality Git can provide.


### Background

There are some things that make software development difficult:

* Working in a team where individuals are all working on a project at once, or where one or more members of the team are geographically separated from the rest
* Mistakes happen. How do you revert back to a working version of your code?
* When it is time to release your software, how do you keep track of different versions of the code?

These are just a few of the problems Git helps address.


### So... What is Git?

Objectively speaking, Git is a *program* that keeps track of the changes you make to files in a project. Subjectively, Git is a *system* and a *mindset* that allows you to write code smartly. For those who use it fully, Git can even define the way they approach working on a problem.

Think of Git as a ledger that keeps track of your work. While you work on the files in a code project, lines are added, modified, and deleted. Much like the [written representation of a chess game](http://en.wikipedia.org/wiki/Algebraic_notation_%28chess%29), if you know the initial state of a file and how its contents are changed over time, you can reconstruct the changes.

| Date | Commit |
| ---- | ------ |
| A few days ago | Created a new file called `myScript.sh` with contents “...” |
| Yesterday      | Changed `rm -rf` to `rm -r` on line 6 of `myScript.sh`.     |
| Today          | Added `# This script does...` between lines 1 and 2 in `myScript.sh`. |
{: .gs-ledger}

As you work and edit your files, you periodically "commit" those changes. Each commit has a message attached to it, where you describe the changes you've made. Later on, you can look back at the commits you've made using `git log` to see your progress.


### Why should we bother?

Let's imagine you make a change to your code that breaks everything. Instead of trying to figure out what you did, you can tell Git to revert your files back to a commit where everything worked. Because Git knows about the changes you've made, it can **undo those changes automatically**.

Another reason many people use Git is because it allows multiple people to work on the same project all at once. If you were to have multiple working on the same files, changes that one person makes would be overwritten the next time someone else saves. It's a mess (trust me) and it doesn't work. With Git, you can give everyone a copy of your project. When people commit their changes and push them to a central location, Git will **automatically merge** the changes. This is extremely important, especially if you find yourself working with people who are not geographically close to you.

Finally, Git keeps you accountable. You and others working on a project can see the changes you make. If you commit some awesome code, everyone will be able to tell it's yours. If you commit something that breaks the rest of the code, other people on the project will know who to ask about it.

### So how does it work?

Imagine this setup: you are working on a homework assignment - a Python script - for this class. It's in a folder called `hw100_rob`. Let's jump in and see what's happening:

~~~
AJFoster :: ~ $ cd hw100_rob
AJFoster :: hw100_rob $ git status
fatal: Not a git repository (or any of the parent directories): .git
~~~

What happened? We used a command, `git status`, to check on the status of our git repository (we'll see more about what this does later). However, we haven't created a repository here, so git has nothing to report.

> *To create a git repository, `cd` into the project directory and run `git init`.*

~~~
AJFoster :: hw100_rob $ git init
Initialized empty Git repository in .../hw100_rob/.git/
AJFoster :: hw100_rob $ git status
On branch master

Initial commit

nothing to commit (create/copy files and use "git add" to track)
~~~

Now we have a git repository in the `hw100_rob` directory. When you run `git init`, Git creates a hidden directory, `.git`, in which to store its data. **Don't mess with this directory**, else you could lose your commit history.

We also ran `git status` to see the current status of the files in the directory. Right now, there aren't any files, so Git has nothing to report. In practice, you'll be typing `git status` a lot as you learn how Git behaves in response to your commands.

> *Use `git status` to see the current status of the files in your Git repository.*

Let's create our homework file. Like a good student, we start by adding a comment at the top with our name and other information.

~~~
AJFoster :: hw100_rob $ git status
On branch master

Initial commit

Untracked files:
  (use "git add <file>..." to include in what will be committed)

    my_script.py

nothing added to commit but untracked files present (use "git add" to track)
~~~

Hooray! Git recognizes that we've created the file. Notice that `my_script.py` is listed as an "untracked file". There may be files in your repository that you do not wish to keep track of. For example, if you are working on a web application and publishing the files using Git, you probably don't want to include files that contain passwords.

Now we'll add the file to the repository.

> *Use `git add <filename>` to have Git track a file in the repository.*

If we run `git status` now, we'll see that Git is ready to accept our changes (i.e. the addition of `my_script.py`) in a commit.

~~~
AJFoster :: hw100_rob $ git add my_script.py 
AJFoster :: hw100_rob $ git status
On branch master

Initial commit

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

    new file:   my_script.py

~~~

At this point, `my_script.py` is in "staging". The stage is a place to collect files we're done editing so that we can commit them together. Since we don't have any more files to add to this commit, we'll go ahead and...

~~~
AJFoster :: hw100_rob $ git commit -m "My first commit."
[master (root-commit) ae828d5] My first commit.
 1 file changed, 3 insertions(+)
 create mode 100644 my_script.py
~~~

This commits all of the staged changes to the repository's history. If we make changes in the future and want to revert back to the way things are right now, we can. We'll also be able to look back at the history to see what was changed, along with the message we wrote.

> *Use `git commit -m "<message>"` to commit all of the changes in staging with a short commit message.*

Let's take a look at the log now.

~~~
AJFoster :: hw100_rob $ git log
commit ae828d5fe0722ca5439f7d358fda941d53832e6f
Author: AJ Foster <email@example.com>
Date:   Thu Mar 26 13:03:35 2015 -0400

    My first commit.
~~~

In the output, you see a string of characters representing the commit. For our purposes, think of this simply as a unique tag for every set of changes. It also shows the author, and the time of the commit. Lastly, we see the message attached to it.

> *Use `git log` to see a log of the commit history. Type `q` to exit the log.*


### Is that it?

For the most basic usage of Git... yes, that's all there is to it. You should be aware that there are many aspects of using Git which aren't covered here:

* Etiquette: when working on a team, there are guidelines (which are sometimes not well-documented) about how to use Git in a way that doesn't create more work for everyone else. For example, you shouldn't rewrite the history or "push" your code in such a way that it deletes others' commits.
* Branching: Git has a feature called branching, in which you tell Git to store your current changes in a separate set of history. You can switch back and forth between branches in order to work on something experimental without contaminating the main branch's history.
* Open-sourcing: Git is one way people package their software so the world can see it. You can post your code (using Git) to a site like GitHub so others can download, modify, and use what you wrote.


### How do I get started?

I highly suggest you check out [this resource from Code School](https://try.github.io/). It'll take you though the basic Git tasks, and explain what is happening as you go.


### Important things to remember

* Always run `git status` to see the current state of the repository. You'll learn to do this compulsively as you work.
* Commit often (especially when you are done with a specific task). It'll be easier to revert back if something goes wrong later.
* Practice! Git, like anything, takes practice. It is worth your time to become familiar with Git now *before* you have to use it in a team setting.
* GitHub is a website; Git is the program it uses.

Edit (2021-01-24): The Try Git resource mentioned above, unfortunately, no longer exists. However, the site does link to a number of helpful resources.

<style>
    .gs-ledger {
        border-collapse: collapse;
        margin: 0 auto 1em;
    }
    .gs-ledger td {
        border-bottom: 1px solid var(--ajBorderColor);
        padding: 0.5em 0.5em 0;
    }
</style>