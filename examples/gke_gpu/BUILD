load("@python3_deps//:requirements.bzl", "requirement")
load("@python3_extra_deps//:requirements.bzl", extra_requirement="requirement")
load("@io_bazel_rules_docker//python3:image.bzl", "py3_image")
load("@io_bazel_rules_docker//python:image.bzl", "py_layer")
load("@brezel//rules/doe:gke.bzl", "doe_gke")
load("@brezel_defaults//:gcp.bzl", "REGISTRY", "BUCKET")
load("@brezel//rules/doc:md.bzl", "md_docs")

md_docs()

# Training dependencies
DEPS = [
    requirement("numpy"),
    requirement("dataclasses"),
    extra_requirement("tensorboard"),
    extra_requirement("tensorboardX"),
    extra_requirement("torch"),
    extra_requirement("torchvision"),
    "@brezel//brezel/infra/doe:remote",
]

# Our own python libs
py_library(
    name = "ae_pylib",
    srcs = [
        "__init__.py",
        "ae.py",
    ]
)

# Building training image and pushes it to GCP
# Gathering the deps in one layer and the source code in another for fast image pushes
# TODO: main file train.py is not layered separately, need to find a way to fix this.
py_layer(name = "src_layer", deps = [":ae_pylib"])
py_layer(name = "deps_layer", deps = DEPS)
LAYERS = [":src_layer", ":ae_pylib"]

py3_image(
    name = "ae_train",
    main = "train.py",
    srcs = ["train.py"],
    deps = DEPS,
    layers = LAYERS,
    base = "@brezel//docker:python3_gpu_gke_base",
)

# Creating a design of experiments on the GPU Nodepool
doe_gke(
    name = "ae-gke",
    image = {REGISTRY+"/ae-train-img:dev": ":ae_train"},
    gcs_upload = {"/tmp/results": BUCKET+"/brezel_examples"},
    matrix = ":experiments.mat",
    nodepool = "pool-gpu",
)
