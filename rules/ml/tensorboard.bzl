load("@rules_python//python:defs.bzl", "py_binary")
load("@python3_extra_deps//:requirements.bzl", "requirement")

def _check_data_type_impl(ctx):
    pass

_check_data_type = rule(
    implementation = _check_data_type_impl,
    attrs = {
        "data": attr.label_list(
            allow_files = [".tar", ".tar.gz", ".tar.xz"],
            allow_empty = False,
            mandatory = True,
        ),
    },
)

def ml_tensorboard(name, data=[], visibility=None):
    _check_data_type(name="_{}_check_type".format(name), data=data)
    py_binary(
        name = name,
        main = "@brezel//rules/ml:tools/tensorboard_tar.py",
        args = ["$(locations {})".format(d) for d in data],
        srcs = ["@brezel//rules/ml:tools/tensorboard_tar.py"],
        deps = [requirement("tensorboard")],
        data = data,
        visibility = None,
    )
