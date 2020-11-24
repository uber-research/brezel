load("@brezel//rules/doc:py.bzl", "py_docs")

py_docs(
    srcs = [
        "local/doe.py",
        "remote/doe.py"
    ],
)

py_library(
    name = "local",
    srcs = ["__init__.py"] + glob(["local/*.py"]),
    imports = ["src"],
    visibility = ["//visibility:public"],
)

py_library(
    name = "remote",
    srcs = ["__init__.py"] + glob(["remote/*.py"]),
    imports = ["src"],
    visibility = ["//visibility:public"],
)
