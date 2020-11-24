load("@brezel//rules/doc:md.bzl", "md_docs")

md_docs()

# Makes Bazel's build information available in Python through a buildinfo package
# Adapted from https://gist.github.com/jayeye/14c91816d10d5b899e1baaaaa9ba4848
genrule(
    name = "genpybuildinfo",
    srcs = ["@brezel//brezel/tools/buildinfo:mkpybuildinfo.sh"],
    outs = ["buildinfo.py"],
    cmd = "exec $< > $@",
    stamp = 1,
    tools = ["@brezel//brezel/tools/buildinfo:mkpybuildinfo.sh"],
)

py_library(
    name = "buildinfo",
    srcs = [":genpybuildinfo"],
    visibility = ["//visibility:public"],
)
