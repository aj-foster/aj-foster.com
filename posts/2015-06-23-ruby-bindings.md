---
title: Using Other Lanugages in Ruby
date: 2015-06-23
preview: Notes from my presentation at the University Ruby meetup at Cloudspace.
category: Guide
---

*The following is a written / more accessible version of my presentation. It should include most of what I say aloud, as well as all of the code presented. For more, you can watch the [Youtube video](https://youtu.be/XSNpYvqmuoA) of the entire meetup.*

The purpose of this guide is to demonstrate various ways of running code that is written in other languages from within a Ruby program. Sometimes we need to run some fast code, or use features of another language. *Ugh!* Don't worry, though; it doesn't have to be painful.

We'll begin with everyone's favorite...

### C

When it comes to speed, it is hard to beat C. Sometimes you may find that an operation in Ruby just takes too long, or that you have to interface with someone's legacy code. Either way, you have some options when it comes to running that code from Ruby.

Throughout this guide, we'll use the example of the naïve (recursive, non-memoized) [Fibonacci number](https://en.wikipedia.org/wiki/Fibonacci_number) generator. That is, the following C function:

~~~c
int fib (int n) {

  if (n < 2)
    return n;

  return fib(n-1) + fib(n-2);
}
~~~

This is a somewhat common test for language performance, as the number of function calls made grows exponentially with `n`.

So, let's look at a few ways you could run this code using Ruby.

#### Straight C

You can, of course, run this code by having Ruby make a system call to a compiled C executable. We'll use this as a benchmark for the other methods. Here's what that might look like in code:

`fib.c`:

~~~c
#include <stdio.h>
#include <stdlib.h>

int fib (int n) {

  if (n < 2)
    return n;

  return fib(n - 1) + fib(n - 2);
}

int main (int argc, char **argv) {

  if (argc != 2) {
    printf("Usage: ./fib <n>\n");
    exit(1);
  }

  int result = fib(atoi(argv[1]));
  printf("%d\n", result);

  return 0;
}
~~~

In Ruby:

<pre>
<code>
<span style="color: #f8f8f2">puts</span>&#32;<span style="color: #e6db74">`/path/to/fib 42`</span>
</code>
</pre>

The backticks (\`\`) are just one way of making system calls in Ruby. This method assumes that you've already compiled the C code on your system, and you have a path to the executable handy.

While this may be elementary, don't discount the fact that **it works**... and you can get it running without too much effort.

#### FFI

FFI stands for *Foreign Function Interface*, which is exactly the kind of thing we need. I recommend that you use FFI when you have a larger set of code that you wish to use. You can install FFI in the form of a gem using `gem install ffi`.

Using FFI is a bit more involved. Here's what it looks like:

`fib.c` is the same as above, except that it has been compiled into a shared object file using:

~~~ bash
gcc -c -fPIC -o fib fib.c
gcc -shared -o fib.so fib
~~~

`ffi.rb`

<pre>
<code>
<span style="color: #75715e">#!/usr/bin/env ruby</span>&#32;
<span style="color: #f8f8f2">require </span><span style="color: #e6db74">'ffi'</span>&#32;
&#32;
<span style="color: #66d9ef">module </span><span style="color: #f8f8f2">FibTest</span>&#32;
  <span style="color: #66d9ef">extend</span>&#32;<span style="color: #66d9ef">FFI</span><span style="color: #f92672">::</span><span style="color: #66d9ef">Library</span>&#32;
  &#32;
  <span style="color: #f8f8f2">ffi_lib</span>&#32;<span style="color: #e6db74">'c'</span>&#32;
  <span style="color: #f8f8f2">ffi_lib</span>&#32;<span style="color: #e6db74">'./fib.so'</span>&#32;
  &#32;
  <span style="color: #f8f8f2">attach_function</span>&#32;<span style="color: #e6db74">:fib</span><span style="color: #f8f8f2">,</span>&#32;<span style="color: #f92672">[</span>&#32;<span style="color: #e6db74">:int</span>&#32;<span style="color: #f92672">]</span><span style="color: #f8f8f2">,</span>&#32;<span style="color: #e6db74">:int</span>&#32;
<span style="color: #66d9ef">end</span>&#32;
&#32;
<span style="color: #f8f8f2">result</span>&#32;<span style="color: #f92672">=</span>&#32;<span style="color: #66d9ef">FibTest</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">fib(</span><span style="color: #66d9ef">ARGV</span><span style="color: #f92672">[</span><span style="color: #ae81ff">0</span><span style="color: #f92672">].</span><span style="color: #f8f8f2">to_i)</span>&#32;
<span style="color: #f8f8f2">puts</span>&#32;<span style="color: #e6db74">"Result: "</span>&#32;<span style="color: #f92672">+</span>&#32;<span style="color: #f8f8f2">result</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">to_s</span>
</code>
</pre>

As you can see, the `fib()` function is attached to and callable from the Ruby object. It doesn't much matter what the `fib()` function does beyond that.

You can expose as many functions as you wish in this way, and FFI will handle the language translation. When in doubt, try this method!

#### RubyInline

An alternative to FFI is RubyInline, which - as you'll see in a moment - is a very apt name. I recommend that you use RubyInline when you have very short snippets of code you'd like to run. Like FFI, you can install RubyInline in the form of a gem, via `gem install RubyInline`.

This is going to look a bit messy, but let's see how it works:

`inline.rb`

<pre>
<code>
<span style="color: #75715e">#!/usr/bin/env ruby</span>&#32;
<span style="color: #f8f8f2">require</span>&#32;<span style="color: #e6db74">'inline'</span>&#32;
&#32;
<span style="color: #66d9ef">class</span>&#32;<span style="color: #a6e22e">FibTest</span>&#32;
  <span style="color: #f8f8f2">inline</span>&#32;<span style="color: #66d9ef">do</span>&#32;<span style="color: #f92672">|</span><span style="color: #f8f8f2">builder</span><span style="color: #f92672">|</span>&#32;
    <span style="color: #f8f8f2">builder</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">prefix</span>&#32;<span style="color: #e6db74">"</span>&#32;
<span style="color: #e6db74">      int fib_inner (int n) {</span>&#32;
&#32;
<span style="color: #e6db74">        if (n &lt; 2)</span>&#32;
<span style="color: #e6db74">          return n;</span>&#32;
&#32;
<span style="color: #e6db74">        return fib_inner(n - 1) + fib_inner(n - 2);</span>&#32;
<span style="color: #e6db74">      }"</span>&#32;
&#32;
    <span style="color: #f8f8f2">builder</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">c</span>&#32;<span style="color: #e6db74">"</span>&#32;
<span style="color: #e6db74">      int fib (int n) {</span>&#32;
<span style="color: #e6db74">        return fib_inner(n);</span>&#32;
<span style="color: #e6db74">      }"</span>&#32;
  <span style="color: #66d9ef">end</span>&#32;
<span style="color: #66d9ef">end</span>&#32;
&#32;
<span style="color: #f8f8f2">inline</span>&#32;<span style="color: #f92672">=</span>&#32;<span style="color: #66d9ef">FibTest</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">new</span>&#32;
<span style="color: #f8f8f2">result</span>&#32;<span style="color: #f92672">=</span>&#32;<span style="color: #f8f8f2">inline</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">fib(</span><span style="color: #66d9ef">ARGV</span><span style="color: #f92672">[</span><span style="color: #ae81ff">0</span><span style="color: #f92672">].</span><span style="color: #f8f8f2">to_i)</span>&#32;
<span style="color: #f8f8f2">puts</span>&#32;<span style="color: #e6db74">"Result: "</span>&#32;<span style="color: #f92672">+</span>&#32;<span style="color: #f8f8f2">result</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">to_s</span>
</code>
</pre>


You'll notice we've adapted the code slightly. RubyInline does a lot of translation when it comes to the types of parameters expected by the C functions. Thus, when you want to run a recursive function like `fib()`, it is best to introduce a wrapper function. Here we've moved `fib()` to `fib_inner()` and instead exposed a `fib()` wrapper function to the Ruby world.

The `fib_inner()` function is defined using the `prefix` method, which means that it won't be translated by RubyInline. This is important because it calls itself, and that won't work if RubyInline changes the way it accepts parameters.

#### Comparison

Great, so we have a few methods by which to call C code from Ruby. How do they compare, performance-wise? Here's the raw data:

| Method        | Avg. Runtime (seconds) |
| ------------- | ------------------------- |
| Straight C    | 3.3777779                 |
| Ruby + FFI    | 3.4948946                 |
| RubyInline    | 2.9529457                 |
| Straight Ruby | 64.398319                 |
{: .c-comp}

Interestingly, RubyInline performs faster than using a compiled C executable. Why is this? When we run the C executable, the OS has to create a new process, allocate some memory for the stack and heap of the program, and then supply it with its arguments. RubyInline avoids a lot of that mess by piggy-backing off of the resources already allocated to the Ruby process. This may not appear to be much of an improvement, but it can be significant with repeated calls over time.

### Python

For working with Python in Ruby, you can use the *rubypython* gem. Much like FFI (in fact, it uses FFI libraries), rubypython allows you to expose and interact with Python. Because Python uses an object model, rubypython completes the added task of exposing Python modules and objects to Ruby. You can install rubypython using `gem install rubypython`.

Here's just a quick example of how it works:

`py.rb`

<pre>
<code>
<span style="color: #f92672">&gt;</span>&#32;<span style="color: #f8f8f2">require</span>&#32;<span style="color: #e6db74">'rubypython'</span>&#32;
 <span style="color: #f92672">=&gt;</span>&#32;<span style="color: #66d9ef">true</span>&#32;
<span style="color: #f92672">&gt;</span>&#32;<span style="color: #66d9ef">RubyPython</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">start</span>&#32;
 <span style="color: #f92672">=&gt;</span>&#32;<span style="color: #66d9ef">true</span>&#32;
<span style="color: #f92672">&gt;</span>&#32;<span style="color: #f8f8f2">numpy</span>&#32;<span style="color: #f92672">=</span>&#32;<span style="color: #66d9ef">RubyPython</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">import(</span><span style="color: #e6db74">"numpy"</span><span style="color: #f8f8f2">)</span>&#32;
 <span style="color: #f92672">=&gt;</span>&#32;<span style="color: #f92672">&lt;</span><span style="color: #f8f8f2">module</span>&#32;<span style="color: #e6db74">'numpy'</span>&#32;<span style="color: #f8f8f2">from</span>&#32;<span style="color: #e6db74">'/(...)/numpy/__init__.pyc'</span><span style="color: #f92672">&gt;</span>&#32;
<span style="color: #f92672">&gt;</span>&#32;<span style="color: #f8f8f2">arr</span>&#32;<span style="color: #f92672">=</span>&#32;<span style="color: #f8f8f2">numpy</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">array(</span><span style="color: #f92672">[</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,</span><span style="color: #ae81ff">3</span><span style="color: #f92672">]</span><span style="color: #f8f8f2">)</span>&#32;
 <span style="color: #f92672">=&gt;</span>&#32;<span style="color: #f8f8f2">array(</span><span style="color: #f92672">[</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,</span>&#32;<span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,</span>&#32;<span style="color: #ae81ff">3</span><span style="color: #f92672">]</span><span style="color: #f8f8f2">)</span>&#32;
<span style="color: #f92672">&gt;</span>&#32;<span style="color: #66d9ef">RubyPython</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">stop</span>&#32;
 <span style="color: #f92672">=&gt;</span>&#32;<span style="color: #66d9ef">true</span>
</code>
</pre>

You are, of course, limited by the syntax of both languages. For example, you cannot use the succinct array splicing syntax available in numpy ([::2]). This may be annoying to die-hard python developers. However, the entirety of the Python object/module and its methods are available, inheritable, etc.

### R

As a final note, let's take a brief look at using the R language within Ruby. You can do this using the `rinruby` gem, installed via `gem install rinruby`. Given that you have the R language installed locally, here's how it looks:

<pre>
<code>
<span style="color: #f92672">&gt;</span>&#32;<span style="color: #f8f8f2">require</span>&#32;<span style="color: #e6db74">"rinruby"</span>&#32;
 <span style="color: #f92672">=&gt;</span>&#32;<span style="color: #66d9ef">true</span>&#32;
<span style="color: #f92672">&gt;</span>&#32;<span style="color: #f8f8f2">sample_size</span>&#32;<span style="color: #f92672">=</span>&#32;<span style="color: #ae81ff">10</span>&#32;
 <span style="color: #f92672">=&gt;</span>&#32;<span style="color: #ae81ff">10</span>&#32;
<span style="color: #f92672">&gt;</span>&#32;<span style="color: #f8f8f2">R</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">eval</span>&#32;<span style="color: #e6db74">"x &lt;- rnorm(#{</span><span style="color: #f8f8f2">sample_size</span><span style="color: #e6db74">})"</span>&#32;
<span style="color: #75715e"># (outputs code being run by R)</span>&#32;
<span style="color: #f92672">&gt;</span>&#32;<span style="color: #f8f8f2">R</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">eval</span>&#32;<span style="color: #e6db74">"summary(x)"</span>&#32;
<span style="color: #f92672">.</span><span style="color: #f8f8f2">RINRUBY</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">PARSE</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">STRING</span>&#32;<span style="color: #f92672">&lt;-</span>&#32;<span style="color: #f8f8f2">rinruby_get_value()</span>&#32;
<span style="color: #f8f8f2">rinruby_parseable(</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">RINRUBY</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">PARSE</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">STRING)</span>&#32;
<span style="color: #f8f8f2">rm(</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">RINRUBY</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">PARSE</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">STRING)</span>&#32;
<span style="color: #f8f8f2">summary(x)</span>&#32;
    <span style="color: #66d9ef">Min</span><span style="color: #f92672">.</span>&#32;&#32;<span style="color: #ae81ff">1</span><span style="color: #f8f8f2">st</span>&#32;<span style="color: #66d9ef">Qu</span><span style="color: #f92672">.</span>&#32;&#32;&#32;<span style="color: #66d9ef">Median</span>&#32;&#32;&#32;&#32;&#32;<span style="color: #66d9ef">Mean</span>&#32;&#32;<span style="color: #ae81ff">3</span><span style="color: #f8f8f2">rd</span>&#32;<span style="color: #66d9ef">Qu</span><span style="color: #f92672">.</span>&#32;&#32;&#32;&#32;&#32;<span style="color: #66d9ef">Max</span><span style="color: #f92672">.</span>&#32;
<span style="color: #f92672">-</span><span style="color: #ae81ff">0</span><span style="color: #f92672">.</span><span style="color: #ae81ff">77660</span>&#32;<span style="color: #f92672">-</span><span style="color: #ae81ff">0</span><span style="color: #f92672">.</span><span style="color: #ae81ff">35550</span>&#32;<span style="color: #f92672">-</span><span style="color: #ae81ff">0</span><span style="color: #f92672">.</span><span style="color: #ae81ff">01425</span>&#32;&#32;<span style="color: #ae81ff">0</span><span style="color: #f92672">.</span><span style="color: #ae81ff">14630</span>&#32;&#32;<span style="color: #ae81ff">0</span><span style="color: #f92672">.</span><span style="color: #ae81ff">67590</span>&#32;&#32;<span style="color: #ae81ff">1</span><span style="color: #f92672">.</span><span style="color: #ae81ff">58500</span>&#32;
<span style="color: #f8f8f2">print(</span><span style="color: #e6db74">'RINRUBY.EVAL.FLAG'</span><span style="color: #f8f8f2">)</span>&#32;
 <span style="color: #f92672">=&gt;</span>&#32;<span style="color: #66d9ef">true</span> 
</code>
</pre>

This is just a quick summary, as found in the [rinruby documentation](https://sites.google.com/a/ddahl.org/rinruby-users/documentation).

### Wrapping Up

We like to write Ruby code, so we should do so whenever possible. If the need to use code written in another language arises, there's no need to adopt that lanugage completely. With a few tools, you can use Ruby as a glue for your libraries and legacy codebases.

Have a comment or correction? Send me a tweet!

Thanks to the following articles for helping me get started:

1. [Calling C/C++ from Ruby](https://www.amberbit.com/blog/2014/6/12/calling-c-cpp-from-ruby/)
2. [Rubypython](https://github.com/halostatue/rubypython)
3. [R in Ruby Quick Start](https://sites.google.com/a/ddahl.org/rinruby-users/documentation)


<style>
  .c-comp {
    border-collapse: collapse;
    margin: 1rem auto 1.5rem;
  }
  .c-comp td, .c-comp th {
      border-bottom: 1px solid var(--ajBorderColor);
      padding: 0.5em;
      text-align: center;
  }
</style>