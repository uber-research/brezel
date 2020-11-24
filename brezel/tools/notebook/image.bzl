load("@python3_deps//:requirements.bzl", "requirement")
load("@python3_extra_deps//:requirements.bzl", extra_requirement="requirement")
load("@io_bazel_rules_docker//python3:image.bzl", "py3_image")
load("@io_bazel_rules_docker//python:image.bzl", "py_layer")

def notebook_image(name, base="@brezel//docker:python3_base", visibility=None, **kwargs):
    jupyter_py = "@brezel//brezel/tools/notebook:jupyter.py"
    py3_image(
        name = name,
        main = jupyter_py,
        srcs = [jupyter_py],
        layers = ["_{}_layer".format(name)],
        base = base,
        visibility = visibility,
        **kwargs,
    )
    py_layer(
        name = "_{}_layer".format(name),
        deps = [
            requirement("click"),
            requirement("numpy"),
            extra_requirement("notebook"),
            extra_requirement("pandas"),
        ],
    )
