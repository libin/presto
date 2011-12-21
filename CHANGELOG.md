Dec 22 2011
---

**Test Framework Refactored**

At the very beginning, Presto were using #assert_* syntax for
assertions.
But fingers started complaining.
So i refactored it to use object proxies, and it became were easy to
write assertions.
However, this added a lot of confusing in implementation and in using
itself, departing from KISS principle.
From now on, Presto will use natural assertions, meant you pass a
block and you can test objects equality, type, value etc in natural
way.
Just like:
t { 'some object' == 'some another object'  }
t { 'some object' > 'some another object'  }
t { 'some object'.nil? }
t { 'some object'.is_a? String }
etc
Test passing if block returns a positive value.
If you need to output an custom error message, pass it as first
argument:
t('error message') { 'some logic' }
