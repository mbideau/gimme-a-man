# gimme-a-man

Produce a manual page from the `--help` of a program (like
[*GNU* *help2man*](https://www.gnu.org/software/help2man/)).

It is a single file *POSIX* shell script of ~ 390 lines of code (without blanks and comments).

![Release](https://img.shields.io/github/v/release/mbideau/gimme-a-man)
![Release Date](https://img.shields.io/github/release-date/mbideau/gimme-a-man)  
![Build](https://github.com/mbideau/gimme-a-man/workflows/build/badge.svg)
![Shellcheck](https://github.com/mbideau/gimme-a-man/workflows/Shellcheck/badge.svg)
![Shell POSIX](https://img.shields.io/badge/shell-POSIX-darkgreen)  
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)

## USAGE

This is the output of `gimme-a-man --help` :
<!-- START makefile-doc -->

```text

gimme-a-man - generate a "man page" with the "troff" format, from a program's help output.

USAGE

    gimme-a-man [OPTIONS] PROG_BIN PROG_NAME PROG_VERSION MAN_SECT_NUM
    gimme-a-man [OPTIONS] -f|--file HELP_FILE PROG_NAME PROG_VERSION MAN_SECT_NUM

    gimme-a-man -H|--help2man PROG_BIN [ -- ..HELP2MAN_ARGS.. ]

    gimme-a-man -h|--help
    gimme-a-man -v|--version


ARGUMENTS

    PROG_BIN
        Path of the program binary.
        It will be executed with the option '--help'.

    PROG_NAME
        Name of the program.

    PROG_VERSION
        Version of the program.

    MAN_SECT_NUM
        Man page section number.

    HELP_FILE
        A file containing the program's help output.

    ..HELP2MAN_ARGS..
        Arguments passed to the GNU help2man binary


OPTIONS

    -l | --locale LOCALE
        The language to use when calling the program.
        This will set the variable LANGUAGE to the provided language.
        See 'GNU gettext' documentation for its definition.

    -f | --file
        Use the specified file as the program's help output.

    -o | --help-option OPTION
        Use the specified option instead of calling the program with '--help'.

    -H | --help2man
        Use the GNU help2man binary to produce the man page.

    -h | --help
        Display help message.

    -v | --version
        Display version and license informations.


EXAMPLES

    Produce the french man page for 'gimme-a-man'
    $ gimme-a-man -l fr_FR.UTF-8 gimme-a-man gimme-a-man "$(gimme-a-man --version | head -n 1)" 1 > /tmp/gimme-a-man.nice.fr.man

    Read it with the 'man' command
    $ man /tmp/gimme-a-man.nice.fr.man


    Produce the french man page for 'gimme-a-man' with the help2man binary
    $ gimme-a-man gimme-a-man --help2man -- -L fr_FR.UTF-8 --section 1 > /tmp/gimme-a-man.less-nice.man

    Read it with the 'man' command
    $ man /tmp/gimme-a-man.less-nice.man


    Save the help message for 'gimme-a-man'
    $ gimme-a-man --help > /tmp/gimme-a-man.help.txt

    Produce the man page for 'gimme-a-man' from the file containing the help output
    $ gimme-a-man --file /tmp/gimme-a-man.help.txt gimme-a-man "$(gimme-a-man --version | head -n 1)" 1 > /tmp/gimme-a-man.nice.man

    Read it with the 'man' command
    $ man /tmp/gimme-a-man.nice.man


ENVIRONMENT

    DEBUG
        Print debugging information to 'STDERR' only if var DEBUG='gimme-a-man'.

    LANGUAGE
    LC_ALL
    LANG
    TEXTDOMAINDIR
        Influence the translation.
        See GNU gettext documentation.


AUTHORS

    Written by: Michael Bideau


REPORTING BUGS

    Report bugs to: <https://github.com/mbideau/gimme-a-man/issues>


COPYRIGHT

    Copyright © 2020-2021 Michael Bideau.
    License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.


SEE ALSO

    Home page: <https://github.com/mbideau/gimme-a-man>
```

<!-- END makefile-doc -->


## Installation

### Using `git` and `make`

Install the required dependencies (example for *Debian* / *Ubuntu*)

```sh
~> sudo apt install git make gettext gzip tar grep sed mawk coreutils
```

Get the sources

```sh
~> git clone -q https://github.com/mbideau/gimme-a-man
~> cd gimme-a-man
~> make install
```

This will install it to `/usr/local/bin/gimme-a-man`.

If you want to install it to /usr/bin, just replace the last instruction by :  

```sh
~> make install prefix=/usr
```

### The raw / hacker way, using `wget` or `curl`

Extract the SHELL script from the repository :

```sh
~> wget "https://raw.githubusercontent.com/mbideau/gimme-a-man/main/gimme_a_man.sh" /usr/local/bin/gimme-a-man
~> chmod +x /usr/local/bin/gimme-a-man
```

You will not have the translations though, which could prevent you to correctly handle translated
`--help` message.


## An alternative to *GNU* *help2man*

### Why ? Reason to be

The [*GNU* *help2man*](https://www.gnu.org/software/help2man/) utility purpose is to produce
*man* page from a from program's help output (when the program is called with the `--help` option).

The way the *man* page is produced by `help2man` from the output of my programs, is not what I
expected and consider good quality documentation. It's kind of broken.

I tried to be friendly with `help2man` by wrapping around the output of my `--help` message to
format it in a way that *help2man* can better understand, but without great success.  
I still had copyright in double (even with option `--no-info`), a badly formatted long option
descriptions, and some minor other weird stuff.

It is not an issue with `help2man` itself but more that **my style of writing help message**
is not matching the one `help2man` likes.  
You have an example of that in this current document at the top in section USAGE.

So I needed a tool for my programs to help me produce the *man* page from the output of their
`--help` message in an automated way.

I consider a good practice to not maintain a hand written man page separately in addition with the
`--help` output, because it could be out of sync and a then generate a really bad user experience.  
There is also not a good reason to not provide the full help version of a program when called with
the `--help` option. Back in time it was smart to separate the short version of `--help` and the
full documentation in `man` or `info` in order to save some kilobytes in the program, but now, with
all the space we have in disk and in memory, not anymore.

After reviewing the prior art (see below) and concluded that nothing was good for my needs I went
with writing my own (rapidly and raw, but does the job).

### Prior art analysis

As the time of writing this (i.e.: Dec. 2020), I have found 21 projects with the name `help2man`
on *Github* and 2 on *Gitlab*.  
All of them are just forks of the *GNU help2man*, or specs files to build it/patch it.
Not helpful.

### Solution

Once I decided that I was going to write my own program to do the same job, but better for my use
case, I had to come up with a way to parse the output of the `--help` in order to produce a man
page.

#### Name

The name `gimme-a-man` is related to the fun
[easter egg in the `man` binary](https://git.savannah.nongnu.org/cgit/man-db.git/commit/src/man.c?id=002a6339b1fe8f83f4808022a17e1aa379756d99)
that lasted from 2011 to 2017.

#### Output: *troff* formatting

For the *man* page format (there are multiple ones supported), I choose to stick with the *troff*
format, even if *Texinfo* is recommended, because it was way simpler for me to manipulate to
achieve my goal in short time.

Despite its simplicity and old age, it was not easy (i.e.: few minutes) to understand how
`troff/groff` worked, and especially to know that I should use the specific set of `groff` macros
for `man` and find a proper documentation for this set.

Anyway, I found the following resources :

* [Man page for the groff man macros](https://linux.die.net/man/7/groff_man)
* [Home page of the groff GNU project](https://www.gnu.org/software/groff/)
* [Wikipedia page of Troff](https://en.wikipedia.org/wiki/Troff)
* [French forum post about the history of groff](https://linuxfr.org/news/groff-sort-en-version-121)

#### Parsing: POSIX SHELL reading line by line the `--help` output

Now I had the format, I had to design a way to parse the output, quick and dirty, because this is
just me trying to produce a man page for another "real" program that I want to document. So this one
is just a side project, which I had not intended to do, and I don't want to spent time on it.

My reflex : a good POSIX SHELL that reads the file line by line.  
This is what you got here.

#### Features list

Cool features implemented :

* tries to preserve as much as possible the existing indentation
* highlight the program name in section *USAGE* or *SYNOPSIS*
* highlight options definitions in section OPTIONS correctly (formatted either with `-s | --long` or
  `-s, --long`)
* underline or italic on tags of sections *ARGUMENTS*, *FILES* and *ENVIRONMENT*
* support multiple tags for one definition (one on each line with same indentation) in sections
  *FILES* and *ENVIRONMENT*
* preserve tailing backslashes `\`, especially those in the example section to indicate a
  non-breaking line
* escape `..` (dot dot) when at the beginning of a `troff` line (which will be discarded else)
* matches automatically the target *man section name/title* from the *man section number*
* supports translations through option `--locale`
* is translated (with `gettext`)
* can produce the same output as the original *GNU help2man* (with option `--help2man`), by wrapping
  around it and calling it, so you can compare both outputs to see which one fits your needs/style

Technical features :

* [KISS](https://simple.wikipedia.org/wiki/KISS_(principle)): simple construction with a few
  lines of SHELL, with no dependency (except some *GNU coretuils* binaries)
* portable *POSIX SHELL*, syntaxically checked with `shellcheck`
* *Makefile* that automatically build locales and man pages, but also `dist` to get a tarball of the
  sources
* have debugging with environment variable `DEBUG=gimme-a-man`

#### Limits / flaws

It does the job, but have some limits.

First it is not unit tested, and I only use it for my own purpose, which means their might have bugs
(big ones) lying around.

Then I choose not (or gave up) implementing some feature that would have been nice to have.

For example: highlighting options and arguments in the USAGE or SYNOPSIS section is not available
because the way to "encode"/"implement it" is really cumbersome : i.e. tries to be smart by removing
spaces, and alternating automatically between *Roman* and *Bold*, etc. I tried to do it properly but
I cannot manage to get a satisfying output in a few hours so I gave up on that feature. Though,
maybe it is better for readability anyway.

It also see lines beginning with a dash `-` as an option, so it is recommended to use the wildcard
`*` to create bullet-point list.


## Test it : its portable SHELL after all, just one `wget`/`curl` away

The best I can recommend is try it out, and see for yourself if it matches your needs.


## Feedbacks wanted, PR/MR welcome

If you have any question or wants to share your uncovered case, please I be glad to answer and
accept changes through *Pull Request*.


## Developing

Install the required dependencies (example for *Debian* / *Ubuntu*)

```sh
~> sudo apt install git make pre-commit shellcheck gettext gzip tar grep sed mawk coreutils
```

Install [markdownlint](https://github.com/markdownlint/markdownlint) in the path

```sh
~> sudo apt install bundler
~> mkdir -p /usr/local/lib/markdownlint
~> cat > /usr/local/lib/markdownlint/Gemfile <<ENDCAT
source 'https://rubygems.org'
gem 'mdl'
ENDCAT
~> cd /usr/local/lib/markdownlint
~> bundler install
~> cd -
~> mdl --version
```

Get the sources

```sh
~> git clone -q https://github.com/mbideau/gimme-a-man
~> cd gimme-a-man
```

Update the [pre-commit](http://pre-commit.com/) environments, then install the hooks,
and run the pre-commit hooks against all files to ensure everything is functional

```sh
~> pre-commit autoupdate
~> pre-commit install
~> pre-commit install --hook-type commit-msg
~> pre-commit install --hook-type pre-push
~> pre-commit run --all-files
~> pre-commit run gitlint --hook-stage commit-msg --commit-msg-filename .git/COMMIT_EDITMSG
```

Note: if you get the following error, just ignore it a re-run the last command that produces it

```sh
~> pre-commit run --all-files
[INFO] Initializing environment for https://github.com/jumanjihouse/pre-commit-hooks:shellcheck.
[INFO] Installing environment for https://github.com/jumanjihouse/pre-commit-hooks.
[INFO] Once installed this environment will be reused.
[INFO] This may take a few minutes...
An unexpected error has occurred: CalledProcessError: command: ('/usr/bin/ruby', '/usr/bin/gem', 'install', '--no-document', '--no-format-executable', 'fake_gem__-0.0.0.gem')
return code: -9
expected return code: 0
stdout: (none)
stderr: (none)
Check the log at /root/.cache/pre-commit/pre-commit.log
```

Once everything is set up, do your changes, then, in the source directory, just run :

```sh
~> make
```

When you are ready to commit your modifications, remember that the commit message follows the
[Conventional Commits](https://www.conventionalcommits.org/) specification, with a **title length
limited to 50 chars**.


## Distribution

If you want a clean tarball of the sources, you can run :

```sh
~> make dist
```

## Copyright and License GPLv3

Copyright © 2020-2021 Michael Bideau [France]

This file is part of gimme-a-man.

gimme-a-man is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

gimme-a-man is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along with gimme-a-man. If not,
see <[https://www.gnu.org/licenses/](https://www.gnu.org/licenses/)>.



## Code of conduct

Please note that this project is released with a *Contributor Code of Conduct*. By participating in
this project you agree to abide by its terms.
