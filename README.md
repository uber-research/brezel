---
title: How to use Brezel
layout: default
nav_order: 1
permalink: /howto
---
Brezel
------

Brezel is a software development framework based on Bazel created to support
modern and reproducible Research. The main idea behind Brezel is to mitigate
technical debt in Research Code while preserving the ability to move fast and test
new ideas quickly. Other advantages of using Brezel for your research projects including
easy description of design of experiments (DOEs), deployment at scale on the cloud,
a ready-to-use polyglot development environment (Python, C++, Scala, Go, NodeJS, ...)
as well as a polyglot documentation system. 

### Your research pipeline as a Bazel Graph
Brezel assumes that you are familiar with Bazel. If not, you should probably take
some time getting acquainted to Bazel and the Bazel Graph.

Prerequisites
-------------
You will either need a Linux distribution or Mac OS to use Brezel. We are not planning
to support Windows in the foreseeable future. Minimal dependencies are needed to get
started, which are `docker`, `docker-compose`, `git` and `zsh`. 

Installation
------------
The installation is straightforward given that you have `docker[-compose]`, `git`
and `zsh` installed. 

On a Debian-based Linux distribution, you can get these using:
```
sudo apt-get install docker docker-compose git zsh
```

Then you just need to clone this repository and add the following command line to either
`~/.bashrc`, or `~/.zshrc` depending on the terminal environment you are using.
```
source path/to/brezel/cli/brzl_init
```

Basic Usage
-----------
You're reading to use Brezel's command-line interface: `brzl`. 
Start creating a new project using `brzl new`. You will end up in a new folder
equipped with a git repository with the following structure:
```
├── BUILD
├── docker
│   ├── dc-extends-ci.yml
│   ├── docker-compose.yml
│   └── Dockerfile
├── Makefile
├── README.md
├── src
│   └── BUILD
├── third_party
│   └── brezel
└── WORKSPACE
```

From now on, you will mostly be using `brzl run` to enter the containerized
development environment that we cooked for you. You are now ready to code, the `src` 
folder is mounted in the container, so feel free to use your favorite IDE. You code
will be built and run using `bazel build` and `bazel run`.

Run the examples
----------------
TBD
