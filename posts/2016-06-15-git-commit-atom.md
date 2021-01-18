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

<pre>
<code>
<span style="color: #75715e">#!/bin/bash</span>&#32;
&#32;
<span style="color: #75715e"># Get the location of the file to edit from Git.</span>&#32;
<span style="color: #f8f8f2">FILE_TO_EDIT</span><span style="color: #f92672">=</span><span style="color: #e6db74">"</span><span style="color: #f8f8f2">$1</span><span style="color: #e6db74">"</span>&#32;
&#32;
<span style="color: #75715e"># If the file we're editing is a commit message, we can assume Atom is set up</span>&#32;
<span style="color: #75715e"># to insert the magic token when the editor closes. Otherwise, we need to let</span>&#32;
<span style="color: #75715e"># Atom tell Git when it is done.</span>&#32;
<span style="color: #75715e">#</span>&#32;
<span style="color: #66d9ef">if</span>&#32;<span style="color: #f92672">[[</span>&#32;<span style="color: #66d9ef">$(</span>basename <span style="color: #e6db74">"</span><span style="color: #f8f8f2">$FILE_TO_EDIT</span><span style="color: #e6db74">"</span><span style="color: #66d9ef">)</span>&#32;<span style="color: #f92672">==</span>&#32;<span style="color: #e6db74">"COMMIT_EDITMSG"</span>&#32;<span style="color: #f92672">]]</span>&#32;
<span style="color: #66d9ef">then</span>&#32;
  <span style="color: #75715e"># Tell Atom to open the file in an existing window.</span>&#32;
  atom <span style="color: #e6db74">"</span><span style="color: #f8f8f2">$FILE_TO_EDIT</span><span style="color: #e6db74">"</span>&#32;
  &#32;
  <span style="color: #75715e"># Wait for Atom to write the magic marker - ##ATOM EDIT COMPLETE## - to signal</span>&#32;
  <span style="color: #75715e"># that the editor has been closed.</span>&#32;
  <span style="color: #75715e">#</span>&#32;
  tail -f <span style="color: #e6db74">"</span><span style="color: #f8f8f2">$FILE_TO_EDIT</span><span style="color: #e6db74">"</span>&#32;<span style="color: #f8f8f2">|</span>&#32;<span style="color: #66d9ef">while</span>&#32;<span style="color: #f8f8f2">read</span> LOGLINE
  <span style="color: #66d9ef">do</span>&#32;
    <span style="color: #f92672">[[</span>&#32;<span style="color: #e6db74">"</span><span style="color: #f8f8f2">$LOGLINE</span><span style="color: #e6db74">"</span>&#32;<span style="color: #f92672">==</span>&#32;<span style="color: #e6db74">"##ATOM EDIT COMPLETE##"</span>&#32;<span style="color: #f92672">]]</span>&#32;<span style="color: #f92672">&amp;&amp;</span> pkill -P <span style="color: #f8f8f2">$$</span> tail
  <span style="color: #66d9ef">done</span>&#32;
&#32;
<span style="color: #66d9ef">else</span>&#32;
  <span style="color: #75715e"># Tell Atom to open the file in a new window and report when it is finished.</span>&#32;
  atom --wait <span style="color: #e6db74">"</span><span style="color: #f8f8f2">$FILE_TO_EDIT</span><span style="color: #e6db74">"</span>&#32;
<span style="color: #66d9ef">fi</span>
</code>
</pre>

For now, let's pretend that script is located in `/usr/local/bin/git-commit-atom.sh`. You'll need to make sure the script is executable by using `chmod +x /usr/local/bin/git-commit-atom.sh` By setting this script as our editor, Git will interact with it instead of Atom directly. Before we do that, however, we need Atom to write a magic token to the end of the commit message when we've finished editing it. To do that, insert this into your Atom Init Script:

<pre>
<code>
<span style="color: #75715e"># This writes a magic token to the end of a commit message. We expect this to</span>&#32;
<span style="color: #75715e"># be run when the commit message editor has been closed.</span>&#32;
<span style="color: #75715e">#</span>&#32;
<span style="color: #f8f8f2">commit_msg_notifier = </span><span style="color: #a6e22e">(path) -&gt;</span>&#32;
  <span style="color: #f8f8f2">process = </span><span style="color: #a6e22e">require</span><span style="color: #f8f8f2">(</span><span style="color: #e6db74">"child_process"</span><span style="color: #f8f8f2">)</span>&#32;
  <span style="color: #a6e22e">process</span><span style="color: #f8f8f2">.</span><span style="color: #a6e22e">exec</span><span style="color: #f8f8f2">(</span><span style="color: #e6db74">"echo \"##ATOM EDIT COMPLETE##\" &gt;&gt; "</span>&#32;<span style="color: #f92672">+</span>&#32;<span style="color: #a6e22e">path</span><span style="color: #f8f8f2">.</span><span style="color: #a6e22e">replace</span>&#32;<span style="color: #f92672">/</span><span style="color: #f8f8f2">(</span><span style="color: #960050; background-color: #1e0010">\</span><span style="color: #a6e22e">s</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #a6e22e">g</span><span style="color: #f8f8f2">,</span>&#32;<span style="color: #e6db74">'\\$1'</span><span style="color: #f8f8f2">)</span>&#32;
&#32;
<span style="color: #75715e"># The following looks at all new editors. If the editor is for a COMMIT_EDITMSG</span>&#32;
<span style="color: #75715e"># file, it sets up a callback for a magic token to be written when the editor</span>&#32;
<span style="color: #75715e"># is closed.</span>&#32;
<span style="color: #75715e">#</span>&#32;
<span style="color: #f8f8f2">setup_commit_msg_notifier = </span><span style="color: #a6e22e">(editor) -&gt;</span>&#32;
  <span style="color: #66d9ef">if</span>&#32;<span style="color: #a6e22e">editor</span><span style="color: #f8f8f2">.</span><span style="color: #a6e22e">buffer</span><span style="color: #f92672">?</span><span style="color: #f8f8f2">.</span><span style="color: #a6e22e">file</span><span style="color: #f92672">?</span><span style="color: #f8f8f2">.</span><span style="color: #a6e22e">getBaseName</span><span style="color: #f8f8f2">()</span>&#32;<span style="color: #f92672">==</span>&#32;<span style="color: #e6db74">"COMMIT_EDITMSG"</span>&#32;
    <span style="color: #f8f8f2">path = </span><span style="color: #a6e22e">editor</span><span style="color: #f8f8f2">.</span><span style="color: #a6e22e">buffer</span><span style="color: #f8f8f2">.</span><span style="color: #a6e22e">file</span><span style="color: #f8f8f2">.</span><span style="color: #a6e22e">getPath</span><span style="color: #f8f8f2">()</span>&#32;
    <span style="color: #a6e22e">editor</span><span style="color: #f8f8f2">.</span><span style="color: #a6e22e">onDidDestroy</span>&#32;<span style="color: #a6e22e">-&gt;</span>&#32;
      <span style="color: #a6e22e">commit_msg_notifier</span><span style="color: #f8f8f2">(</span><span style="color: #a6e22e">path</span><span style="color: #f8f8f2">)</span>&#32;
&#32;
  <span style="color: #75715e"># Return this, else weird things may happen. Anyone understand why?</span>&#32;
  <span style="color: #66d9ef">true</span>&#32;
&#32;
<span style="color: #75715e"># Set up for all editors to be screened for commit messages.</span>&#32;
<span style="color: #a6e22e">atom</span><span style="color: #f8f8f2">.</span><span style="color: #a6e22e">workspace</span><span style="color: #f8f8f2">.</span><span style="color: #a6e22e">observeTextEditors</span><span style="color: #f8f8f2">(</span><span style="color: #a6e22e">setup_commit_msg_notifier</span><span style="color: #f8f8f2">)</span>
</code>
</pre>

After reloading Atom (restart the application or use View > Developer > Reload Window) we should be ready to try it out. Use this to try it out on one git repo:

`git config core.editor "/usr/local/bin/git-commit-atom.sh"`

And use this to set it for all of your projects:

`git config --global core.editor "/usr/local/bin/git-commit-atom.sh"`

Now, when you use `git commit`, the commit message should open in your most recently active Atom window. Atom will write a token at the end of the commit message file, and the managing script will tell Git when you're finished writing.

How does it work for you? Feel free to tweet or message me with feedback; it's appreciated.