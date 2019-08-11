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

This repo comes with scripts for managing NodeJS installs:

```sh
# install a specific NodeJS version
$ script/install-node 10.16.2
```

Write a version to a `.node-version` file to use that version in the directory containing the `.node-version` file. This requires that you have previously installed that version:

```sh
# set the node version for a directory
$ echo 10.16.2 > .node-version
$ node -v
v10.16.2
# change it whenever you need to
$ echo 6.10.2 > .node-version
$ node -v
v6.10.2
```

It's a good idea to create a default version file at `${HOME}/.node-version`.
