---
title: ML on GCP
layout: default
parent: Guides
---
Running Python ML experiments on GCP using Bazel
===============================================

The `BUILD` file featured in this folder showcases training a Pytorch model on GPU on the cloud.

The key is to use the new nodepool `pool-gpu` of our Kubernetes Cluster.

### A few remarks
- The Bazel process is not yet streamlined. For this to work you need to use the following commands (push the image, build the design of experiments, create/delete jobs).
    ```
    bazel run :ae_train_push
    bazel build :ae-gke
    bazel run :ae-gke.[create|delete]
    ```

- When changing your code, rerun `bazel run :ae_train_push` which should be quick as the source has its own layer.

- The base image used does not ship the CUDA/Nvidia drivers. However, GKE takes care of mounting the drivers into your node so this just works.

- For local testing with GPU, enter the development container with `bazel run-cuda` and run:
    ```
    bazel run :ae_train.binary
    ```

- The `experiments.mat` file only contains a single line. If you want to run multiple experiments, make sure your train.py can processes command line arguments (use click) and then populate `experiments.mat` with one line per experiment arguments.
