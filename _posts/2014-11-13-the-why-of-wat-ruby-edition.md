---
layout: post
title: "The Why of \"Wat\" [Ruby edition]"
author: Terrance Kennedy
date: 2014-11-13 23:48:23 -0700
comments: true
categories: [Ruby]
---

In his wonderfully sarcastic lightning talk, Wat, Gary Bernhardt explores the
dark side of Ruby and Javascript with examples that seem to defy logic.  When I
first saw [*Wat*](https://www.destroyallsoftware.com/talks/wat), I immediately
wanted to know more. How do these strange behaviors come about? Is it an
interpreter error, designed into the language, or something else entirely? If
the behavior is intentional, what is the reasoning behind it? I decided to take
the plunge and find out for myself.

<!--more -->

## Let's talk about Ruby

### Undefined variable self assignment

{% highlight ruby %}
a     # => NameError: undefined local variable or method `a' for main:Object
b     # => NameError: undefined local variable or method `b' for main:Object
a = b # => NameError: undefined local variable or method `b' for main:Object
a = a # => nil
{% endhighlight %}

Why would Ruby transform an undefined variable to `nil` in self assignment?
Let's first breakdown a typical variable assignment in Ruby:

{% highlight ruby %}
foo = 4
{% endhighlight %}

1. Ruby initializes `foo` to `nil`.
2. Ruby evaluates the expression on the right-hand side. In this case the
   result is simply `4`.
3. Ruby assigns the result of the right-hand side evaluation (`4`) to `foo`.

And now the same breakdown of a self assignment:

{% highlight ruby %}
foo = foo
{% endhighlight %}

1. Ruby initializes `foo` to `nil`.
2. Ruby evaluates the expression on the right-hand side. To do this, Ruby looks
   up the value of `foo`, which by this point is `nil`.
3. Ruby assigns the result of the right-hand side evaluation (`nil`) to `foo`.

The key point here is that Ruby will always initialize the variable on the
left-hand side *before* evaluating the expression on the right-hand side. This
guarantees that any undefined variables on the left-hand side will be defined
by the time the right-hand side is evaluated.

We now know *how* Ruby allows for self assignment of an undefined variable, but
that still leaves *why*. One reason this seemingly odd behavior exists is to
accommodate a somewhat common idiom -- conditional setting of variables:

{% highlight ruby %}
class TaskList
  def tasks
    @tasks = @tasks || []
  end
end
{% endhighlight %}

(Note that the above is usually written `@tasks ||= []`, though the two
aren't equivalent[^1].)

If `@tasks` is undefined, and Ruby doesn't initialize `@tasks` before
evaluating the right-hand side of the assignment, this idiom would not work as
intended.

### Ruby and bare words

{% highlight ruby %}
ruby has no bare words # => NameError: undefined local variable or method `words'

def method_missing( *args ); args.join(" "); end

ruby has bare words # => "ruby has bare words"
{% endhighlight %}

This one is nothing more than an interesting application of language features,
some more well known than others. The first and probably best known feature is
that parenthesis are optional in Ruby method calls. Because of this, Ruby
interprets `ruby has no bare words` as if we wrote
`ruby( has( no( bare( words ) ) )`. Second, when making a method call, Ruby
searches the current scope for a matching method definition. If it cannot find
one, it passes the method name in question to `method_missing`[^2]. You can define
your own `method_missing` to provide extra runtime functionality. In this case,
our `method_missing` takes the passed in method name (plus zero or more other
arguments) and returns a string of all those arguments joined together. Let's
break up the example to illustrate how the string is built:

{% highlight ruby %}
# Starting with the innermost method call
method_missing( "words" ) # => "words"
method_missing( "bare", "words" ) # => "bare words"
method_missing( "has", "bare words" ) # => "has bare words"
method_missing( "ruby", "has bare words" ) # => "ruby has bare words"
{% endhighlight %}

Ruby behaves this way because part of its core functionality has been broken,
making the *why* pretty pointless here. Note that in Ruby 1.9.3+, arguments are
passed to `method_missing` as symbols instead of strings, which causes infinite
recursion. This is because
[`Array#join`](http://www.ruby-doc.org/core-2.1.4/Array.html#method-i-join)
attempts to convert the symbols to string objects by calling `to_str`, and
since no `to_str` method is defined for the `Symbol` class, the method call
gets passed to -- you guessed it -- `method_missing`.

## Let's talk about Javascript

As it turns out, the Javascript portion of *wat* has already been covered by
Adam Iley's well written
[blog post](http://blog.caplin.com/2012/01/27/the-why-of-wat/). I discovered
this post while researching my own, and was surprised to find it had not only
already been written, but with an identical title! Thanks Adam!

[^1]: <http://dablog.rubypal.com/2008/3/25/a-short-circuit-edge-case>
[^2]: <http://www.ruby-doc.org/core-2.1.0/BasicObject.html#method-i-method_missing>
