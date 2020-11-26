load("@rules_python//python:defs.bzl", "py_library")
load("@python3_deps//:requirements.bzl", "requirement")

py_library(
    name = "gcp",
    srcs = glob(["*.py"], exclude=["*_test.py"]),
    deps = [requirement("google-cloud-storage")],
    data = ["@brezel_defaults//infra:gcp.ini"],
    visibility = ["//visibility:public"],
)
