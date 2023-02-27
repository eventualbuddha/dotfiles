# dotfiles

bootstraps a shell environment and some helpful scripts for installing things I'll be likely to need.

## Install

```sh
# get a local copy
$ git clone git@github.com:eventualbuddha/dotfiles.git
$ cd dotfiles
# install and configure everything
$ ./install
# replace shell with a new one set up just as you like it
$ exec zsh -il
```

## Environment

I want just the basics to get up and running with my usual software development projects. It includes basic prompt, shell, and vim configuration.

### NodeJS

This repo uses `rtx` for managing node versions.

```sh
# install a specific NodeJS version
$ rtx install nodejs 18
```

Write a version to a `.node-version` file or `.tool-versions` to use that
version in the directory containing the file. This requires that you have
previously installed that version:

```sh
# set the node version for a directory
$ echo 16.12.4 > .node-version
$ node -v
v16.12.4
# change it whenever you need to
$ echo 12.19.0 > .node-version
$ node -v
v12.19.0
```
