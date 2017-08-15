---
title: "From Bash to Python for scripting"
date: "2017-08-15"
categories:
    - "development"
    - "linux"
tags:
    - "Linux"
    - "development"
---

I am a huge fan of shell scripting. But recently it did give me very unexpected
behaviour which lead me to start using python for "shell" scripts.

What happened? I was trying to create helpers that called other helpers and
passed the arguments with "$@". This worked fine for a very long time until you
pass along strings like '-e "CREATE DATABASE foo"' to a shell script.

<!--more-->

## The encounter of annoying limits of sh/bash scripting

While creating helpers for a docker related project I encountered some issue I
never experienced before. At first it seemed like it happened sometimes and
sometimes everything was just working fine. So lets try to reproduce the issue
as simple as possible.

What we want to do:

* use helpers
* call helpers from helpers with extra info

## Reproducing the issue

While trying to create a helper for MySQL we started seeing weird issues. First
it was not clear but then it showed, if you pass '-e' to a shell script it
breaks something, the -e does not appear when using "$@".

We have a dummy binary `ourbinary`:

``` sh
#!/usr/bin/env sh

for param in "$@"; do
    echo "$param"
done
```

As you can see this just prints every "parameter" passed in.

To reproduce exactly what the problem is we need 2 helpers, the first one with
some 'default' parameters we always want to be passed to our `ourbinary`. The
second trying to achieve something like creating a default database in MySQL.

`helper1.sh`:

``` sh
#!/usr/bin/env sh

# lets call our binary with some predefined params and all params given here
./ourbinary -a test -b foo "$@"
```

`helper2.sh`:

``` sh
#!/usr/bin/env sh

./helper1.sh -c "bar" -d 'more' -e "CREATE DATABASE myapp default charset utf8"
```

If we now run `helper2.sh` we start seeing the issue.

``` sh
$ ./helper2.sh
-a
test
-b
foo
-c
bar
-d
more

CREATE DATABASE myapp default charset utf8
```

Now we see the '-e' is emptied. Why is not really clear to me.

The first thing we tried was using '$*' instead of '$@'. This does not remove
the '-e' but loses the information where the parameters are separated.

If we change `helper1.sh` to use '$*' instead of '$@' like:

``` sh
#!/usr/bin/env sh

# lets call our binary with some predefined params and all params given to this
./ourbinary -a test -b foo "$*"
```

And we run `./helper2.sh` again we get the following result:

``` sh
$ ./helper2.sh 
-a
test
-b
foo
-c bar -d more -e CREATE DATABASE myapp default charset utf8
```

Now we have lost the proper separation of the parameters given to `helper1.sh`
from `helper2.sh`. In our real life scenario it did consistently fail when we
started using '$*'.

## Hello python

After more fiddling around with sed and other tricks to escape strings and
quotes and trying to make it somewhat useful again I just stopped and started
checking out scripting with python. With the shell setup in place it still had
some issues that were very hard to predict and to solve.

Then I started using python and I started to like it very much. This trigger
will probably be the start of me using a lot more python for scripting,
especially when things are getting a bit complex. My shell scripting will be
reduced a lot by this.

First let me show you the initial result of converting the scripts to python.

`ourbinary`:

``` python
#!/usr/bin/env python

import sys

for param in sys.argv:
    print(param)
```

`helper1.py`:

``` python
#!/usr/bin/env python

import sys, subprocess

# call ourbinary with the parameters given to this
cmd = [ './ourbinary', '-a', 'test', '-b', 'foo'] + sys.argv[1:]

p = subprocess.Popen(cmd)
p.communicate()
sys.exit(p.returncode)
```

`helper2.py`:

``` python
#!/usr/bin/env python

import sys, subprocess

# call ourbinary with the parameters given to this
cmd = [
    './helper1.py', '-c', 'bar', '-d', 'more', '-e',
    "CREATE DATABASE myapp default charset utf8"
]

p = subprocess.Popen(cmd)
p.communicate()
sys.exit(p.returncode)
```

And when we then run `./helper2.py` all is fine and great.

``` sh
$ ./helper2.py 
./ourbinary
-a
test
-b
foo
-c
bar
-d
more
-e
CREATE DATABASE myapp default charset utf8
```

Or not? No `ourbinary` did not behave like we would have used '$@' or '$*'
since the script just used everything in `argv` which also contains the binary
name in position 0. To have it behave like '$@' we must use `sys.argv[1:]`, so
starting from argument 1 to the last argument.

## conclusion

Because if this bizarre issue with shell scripts I just explored a little bit
into python. This brought me to the conclusion I can very much use it for a lot
of things that I usually would write into shell scripts. But when I'm going to
use python I have a fully fledged programming language at my disposal which
will help me do more complex things than I could ever do in shell scripts. The
result will be similar but by using python I think I will end up with more
robust and dependable solutions which will not end up having very special
edgecases.
