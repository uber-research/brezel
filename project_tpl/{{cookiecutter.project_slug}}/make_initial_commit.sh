#!/usr/bin/env bash
git init
git submodule --quiet add {{cookiecutter.research_platform_url}} third_party/{{cookiecutter.research_platform_slug}}
git add .
git commit --quiet --message 'RESEARCH PLATFORM: Initial commit'
