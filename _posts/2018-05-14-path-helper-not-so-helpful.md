---
layout: post
title: "MacOS path_helper not so helpful"
date: 2018-05-14 23:48:23 -0700
categories: bash, zsh, debugging
---

Do you use shell-based version managers like [nvm], [pyenv], or [rbenv], in combination with
[tmux] on macOS? If so, you may be in for a surprise. Outside of tmux and screen, version
managers will work fine, but inside the session, system or [Homebrew] installed tools will be
used instead. What's going on here?

<!--more -->

## Path Helper

MacOS has a utility called `path_helper` that initializes the `PATH` environment variable by
reading paths from _/etc/paths_ and then any file under _/etc/paths.d_. The path helper utility
doesn't technically set the `PATH`, but will output the shell commands to set it accordingly. It is
`eval`'d by the first file sourced on a login shell for sh, bash, and zsh:

```bash
# Code snippet found in /etc/profile and /etc/zprofile
if [ -x /usr/libexec/path_helper ]; then
    eval `/usr/libexec/path_helper -s`
fi
```

## Path Helper and Existing PATH

If you already have a `PATH` variable set when invoking `path_helper`, such as when you start a new
tmux session, `path_helper` will 'intelligently' create a new `PATH` by merging the loaded paths
with existing `PATH` and removing duplicates. The problem is, while `path_helper` deduplicates
paths, it doesn't preserve order. If you have a custom path or paths prepended to the default list
in your _~/.bashrc_ or _~/.zshrc_  and invoke the path helper, your custom path(s) will now be at
the _end_ of the `PATH` variable. This effectively disables all your version managers by
prioritizing system binaries over them.

## Solution

Luckily there is a setting in tmux to tell it to avoid creating a login shell when starting a new
session. This avoids sourcing `/etc/[z]profile`, and `path_helper` does not get invoked. Simply add
this setting to your `tmux.conf` and you should be good to go:

```
# Don't create login shells
set -g default-command "${SHELL}"
```

If having tmux create login shells is somehow a requirement for you, your only other choice is to
create or edit the first user controlled file that gets sourced in a login shell, either
`~/.bash_profile` or `~/.zprofile`, and add some code to fix your `PATH` variable by comparing the
existing `PATH` against the paths generated when running `path_helper` in a clean environment and
then rebuilding the `PATH` variable with user-defined paths prepended to the system-defined paths:

```bash
reorganize_login_subshell_path() {
    # save path as old_path
    local old_path="$PATH"
    # run path_helper against an empty PATH
    PATH=''
    eval `/usr/libexec/path_helper -s`
    # At this point the PATH contains only system-wide paths.

    # If paths are the same this is not a subshell or no user-defined paths are
    # set. In other words, the PATH is correct and there is no work to be done.
    if [ "$old_path" = "$PATH" ]; then
        return
    fi
    # Use parameter substitution to subtract system-wide paths from old_path,
    # leaving only user-defined paths. "${var#Pattern}" means "Remove from $var
    # the shortest part of $Pattern that matches the front end of $var."
    local user_defined_paths="${old_path#$PATH:}"

    # Rebuild PATH with user-defined paths prepended to system-wide paths.
    PATH="$user_defined_paths:$PATH"
}

if [ -x /usr/libexec/path_helper ]; then
    reorganize_login_subshell_path
fi
# remove path reorganization function to avoid cluttering environment
unset -f reorganize_login_subshell_path
```

The latter approach here is not recommended as it attempts to solve the problem of `PATH` munging
with more `PATH` munging, making it all the more difficult to reason about the state of your shell
environment.

[nvm]: https://github.com/nvm-sh/nvm
[pyenv]: https://github.com/pyenv/pyenv
[rbenv]: https://github.com/rbenv/rbenv
[tmux]: https://github.com/tmux/tmux
[Homebrew]: https://brew.sh/
