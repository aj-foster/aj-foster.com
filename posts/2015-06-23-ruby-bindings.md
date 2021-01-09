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

~~~ruby
puts `/path/to/fib 42`
~~~

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

~~~ruby
#!/usr/bin/env ruby

require 'ffi'

module FibTest
  extend FFI::Library

  ffi_lib 'c'
  ffi_lib './fib.so'

  attach_function :fib, [ :int ], :int
end

result = FibTest.fib(ARGV[0].to_i)
puts "Result: " + result.to_s
~~~

As you can see, the `fib()` function is attached to and callable from the Ruby object. It doesn't much matter what the `fib()` function does beyond that.

You can expose as many functions as you wish in this way, and FFI will handle the language translation. When in doubt, try this method!

#### RubyInline

An alternative to FFI is RubyInline, which - as you'll see in a moment - is a very apt name. I recommend that you use RubyInline when you have very short snippets of code you'd like to run. Like FFI, you can install RubyInline in the form of a gem, via `gem install RubyInline`.

This is going to look a bit messy, but let's see how it works:

`inline.rb`

~~~ruby
#!/usr/bin/env ruby

require 'inline'

class FibTest
  inline do |builder|
    builder.prefix "
      int fib_inner (int n) {

        if (n < 2)
          return n;

        return fib_inner(n - 1) + fib_inner(n - 2);
      }"

    builder.c "
      int fib (int n) {
        return fib_inner(n);
      }"
  end
end

inline = FibTest.new
result = inline.fib(ARGV[0].to_i)
puts "Result: " + result.to_s
~~~

You'll notice we've adapted the code slightly. RubyInline does a lot of translation when it comes to the types of parameters expected by the C functions. Thus, when you want to run a recursive function like `fib()`, it is best to introduce a wrapper function. Here we've moved `fib()` to `fib_inner()` and instead exposed a `fib()` wrapper function to the Ruby world.

The `fib_inner()` function is defined using the `prefix` method, which means that it won't be translated by RubyInline. This is important because it calls itself, and that won't work if RubyInline changes the way it accepts parameters.

#### Comparison

Great, so we have a few methods by which to call C code from Ruby. How do they compare, performance-wise? Here's the raw data:

{:.c-comp}
| Method        | Avg. Runtime (s) |
| ------------- | ------------------------- |
| Straight C    | 3.3777779                 |
| Ruby + FFI    | 3.4948946                 |
| RubyInline    | 2.9529457                 |
| Straight Ruby | 64.398319                 |

Interestingly, RubyInline performs faster than using a compiled C executable. Why is this? When we run the C executable, the OS has to create a new process, allocate some memory for the stack and heap of the program, and then supply it with its arguments. RubyInline avoids a lot of that mess by piggy-backing off of the resources already allocated to the Ruby process. This may not appear to be much of an improvement, but it can be significant with repeated calls over time.

### Python

For working with Python in Ruby, you can use the *rubypython* gem. Much like FFI (in fact, it uses FFI libraries), rubypython allows you to expose and interact with Python. Because Python uses an object model, rubypython completes the added task of exposing Python modules and objects to Ruby. You can install rubypython using `gem install rubypython`.

Here's just a quick example of how it works:

`py.rb`

~~~ruby
> require 'rubypython'
 => true
> RubyPython.start
 => true
> numpy = RubyPython.import("numpy")
 => <module 'numpy' from '/(...)/numpy/__init__.pyc'> 
> arr = numpy.array([1,2,3])
 => array([1, 2, 3])
> RubyPython.stop
 => true
~~~

You are, of course, limited by the syntax of both languages. For example, you cannot use the succinct array splicing syntax available in numpy ([::2]). This may be annoying to die-hard python developers. However, the entirety of the Python object/module and its methods are available, inheritable, etc.

### R

As a final note, let's take a brief look at using the R language within Ruby. You can do this using the `rinruby` gem, installed via `gem install rinruby`. Given that you have the R language installed locally, here's how it looks:

~~~ruby
> require "rinruby"
 => true 
> sample_size = 10
 => 10 
> R.eval "x <- rnorm(#{sample_size})"
# (outputs code being run by R)
> R.eval "summary(x)"
.RINRUBY.PARSE.STRING <- rinruby_get_value()
rinruby_parseable(.RINRUBY.PARSE.STRING)
rm(.RINRUBY.PARSE.STRING)
summary(x)
    Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
-0.77660 -0.35550 -0.01425  0.14630  0.67590  1.58500 
print('RINRUBY.EVAL.FLAG')
 => true 
~~~

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
    margin: 0 auto 1em;
  }
  .c-comp td, .c-comp th {
      border-bottom: 1px solid #ddd;
      padding: 0.5em;
      text-align: center;
  }
</style>