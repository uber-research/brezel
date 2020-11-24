---
title: Run on GCP
layout: default
parent: Guides
---
Running Python experiments on GCP using Bazel
=============================================

The `BUILD` file featured in this folder helps you understand the steps necessary to run experiments at Scale using Python and Bazel with Brezel.

1. Use `py3_image` to containerize your python program. 
2. Use `py_binary` rule to test it locally.
3. Finally, the `doe_gke` Bazel macro will allow you to setup and run a Design of Experiments at scale. It also handles the push to our GCP Registry.

### A few remarks
- A detailed guide of `doe_gke` is available on [Brezel's Documentation][TODO].
- `py3_image` doesn't allow you to pass default arguments to the Docker image's entrypoint, so all your arguments will have to appear in the `matrix` file passed to `doe_gke`.
- You need to enter the development container using `make run-k8s-secrets` to use this Bazel pipeline.
