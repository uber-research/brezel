load("@python3_deps//:requirements.bzl", "requirement")
load("@brezel//rules/doc:bzl.bzl", "bzl_docs")

bzl_docs(
    srcs = [
        "doe.bzl",
        "gke.bzl",
    ],
    deps = glob(["**/*.bzl"]) + [
        "@brezel_defaults//:gke.bzl",
        "@brezel_defaults//:gcp.bzl",
        "@io_bazel_rules_k8s//k8s:object.bzl",
        "@io_bazel_rules_docker//container",
    ]
)

py_binary(
    name = "jinja2_renderer",
    main = "tools/j2_to_yaml.py",
    srcs = ["tools/j2_to_yaml.py"],
    deps = [
        requirement('jinja2')
    ],
    visibility = ["//visibility:public"]
)

exports_files(glob([
    "templates/*",
]))

exports_files([
    "tools/config_list.tpl.sh",
])

exports_files([
    "config_factory.bzl",
    "doe.bzl",
    "gke.bzl",
])
