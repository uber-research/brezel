load("@rules_python//python:defs.bzl", "py_binary")
load("@python3_deps//:requirements.bzl", "requirement")
load("@brezel_defaults//:gke.bzl", "NODEPOOLS", "TAINTS")
load("//rules:vars.bzl", "py_vars")

py_binary(
    name = "shell",
    srcs = ["inquirer-shell.py"],
    main = "inquirer-shell.py",
    data = ["pod.yaml.j2", "simple-shell.sh"],
    deps = [
        requirement('jinja2'),
        requirement('pyinquirer'),
        ":vars"
    ],
)

py_vars(
    name = "vars",
    variables = {
        "NODEPOOLS": NODEPOOLS,
        "TAINTS": TAINTS,
    }
)
