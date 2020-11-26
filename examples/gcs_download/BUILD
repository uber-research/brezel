load("@rules_python//python:defs.bzl", "py_binary")

py_binary(
    name = "gcs_download",
    main = "main.py",
    srcs = ["main.py"],
    deps = ["@brezel//brezel/infra/gcp"],
)
