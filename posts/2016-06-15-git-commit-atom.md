---
title: Writing Commit Messages in Atom
layout: article
date: 2016-06-15
preview: A better way to use Atom as your Git commit message editor.
category: Guide
---

**Edit (8-14-2016)**: The previous version of the Init Script for Atom did not handle file paths with spaces in them. A simple replacement (space => backslash space) does the trick.

**Edit (3-27-2017)**: [Matthew Moreno](https://mmore500.github.io/) has created an [Atom package](https://atom.io/packages/git-edit-atom) and corresponding [Golang package](https://github.com/mmore500/git-commit-atom) to set this up for you. It has the benefit of handling other types of Git files (like tag messages, rebase manifests, etc.). Definitely check it out!

---

If you're into writing good commit message for your Git repositories, you probably use the `--verbose` flag with `git commit`. This includes the changes to be committed right in the editor where you write your commit messages, for easy review.

For a long time I've just used `nano` as my commit message editor. This was "good enough" in that it allowed me to edit the message quickly while scrolling through the changes. (Side note: when Mac's Terminal started translating mouse scrolling to console scrolling, this got much easier.) Recently, however, I felt it was time for an upgrade. Given that [Atom](https://atom.io) is my editor of choice at the moment, it made sense to use it for editing commit messages.

Enter trouble.

A quick search may lead you to some [deceptively simple instructions](http://blog.atom.io/2014/03/13/git-integration.html#commit-editor) on how to use Atom to write commit messages. If you've tried it out, you've probably found that the user experience isn't that great. When you run `git commit`, it passes the commit message file location to `atom --wait`. Here, a new Atom instance takes charge. Even if an Atom window is already open, a new one is created just for the commit message. Git has to wait for that new window to be closed (not just the tab / editor with the commit message) before it can continue. The entire process takes longer than it needs to.

Git requires the editor to wait and report a return value for several reasons: it gives the editor an opportunity to abort the commit if something goes wrong; it gives us an opportunity to save the commit message several times before deciding we're finished. Unfortunately Atom does not have the ability to wait on a single tab / text editor, so a new window must be devoted to the task.

### A Solution

To stop this annoying dance of new windows, I wrote some code. You should **use it at your own risk** (Unix / Bash-friendly environments only) and let me know if you have any suggestions for improvement. The goal is to replace `atom --wait` with just plain `atom` to open the commit message file, so it opens quickly in an existing window. We only use the `--wait` flag because Git needs to be told (in this case, by Atom) when you've finished editing the commit message. By putting another process between Git and Atom, we can remove this necessity.

It's all based on the following script, which you would put some place safe (that won't move):

~~~bash
#!/bin/bash

# Get the location of the file to edit from Git.
FILE_TO_EDIT="$1"

# If the file we're editing is a commit message, we can assume Atom is set up
# to insert the magic token when the editor closes. Otherwise, we need to let
# Atom tell Git when it is done.
#
if [[ $(basename "$FILE_TO_EDIT") == "COMMIT_EDITMSG" ]]
then
  # Tell Atom to open the file in an existing window.
  atom "$FILE_TO_EDIT"

  # Wait for Atom to write the magic marker - ##ATOM EDIT COMPLETE## - to signal
  # that the editor has been closed.
  #
  tail -f "$FILE_TO_EDIT" | while read LOGLINE
  do
    [[ "$LOGLINE" == "##ATOM EDIT COMPLETE##" ]] && pkill -P $$ tail
  done

else
  # Tell Atom to open the file in a new window and report when it is finished.
  atom --wait "$FILE_TO_EDIT"
fi
~~~

For now, let's pretend that script is located in `/usr/local/bin/git-commit-atom.sh`. You'll need to make sure the script is executable by using `chmod +x /usr/local/bin/git-commit-atom.sh` By setting this script as our editor, Git will interact with it instead of Atom directly. Before we do that, however, we need Atom to write a magic token to the end of the commit message when we've finished editing it. To do that, insert this into your Atom Init Script:

~~~coffee
# This writes a magic token to the end of a commit message. We expect this to
# be run when the commit message editor has been closed.
#
commit_msg_notifier = (path) ->
  process = require("child_process")
  process.exec("echo \"##ATOM EDIT COMPLETE##\" >> " + path.replace /(\s)/g, '\\$1')

# The following looks at all new editors. If the editor is for a COMMIT_EDITMSG
# file, it sets up a callback for a magic token to be written when the editor
# is closed.
#
setup_commit_msg_notifier = (editor) ->
  if editor.buffer?.file?.getBaseName() == "COMMIT_EDITMSG"
    path = editor.buffer.file.getPath()
    editor.onDidDestroy ->
      commit_msg_notifier(path)

  # Return this, else weird things may happen. Anyone understand why?
  true

# Set up for all editors to be screened for commit messages.
atom.workspace.observeTextEditors(setup_commit_msg_notifier)
~~~

After reloading Atom (restart the application or use View > Developer > Reload Window) we should be ready to try it out. Use this to try it out on one git repo:

`git config core.editor "/usr/local/bin/git-commit-atom.sh"`

And use this to set it for all of your projects:

`git config --global core.editor "/usr/local/bin/git-commit-atom.sh"`

Now, when you use `git commit`, the commit message should open in your most recently active Atom window. Atom will write a token at the end of the commit message file, and the managing script will tell Git when you're finished writing.

How does it work for you? Feel free to tweet or message me with feedback; it's appreciated.