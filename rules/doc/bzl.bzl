load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

def bzl_docs(srcs, visibility = ["@brezel//site:__pkg__"],
             deps = []):
    # Creating a bzl_library for the user
    bzl_library(
        name = "_bzl_lib",
        srcs = deps if len(deps) > 0 else native.glob("**/*.bzl")
    )

    # Generating md files from Starlark
    [stardoc(
        name = "stardoc_raw/"+src,
        input = src,
        out = src+"_raw.md",
        deps = [":_bzl_lib"],
    ) for src in srcs]

    # Adding a header for Jekyll features
    [native.genrule(
        name = "stardoc/"+src,
        srcs = [src+"_raw.md"],
        outs = [src+".md"],
        cmd = """
cat > $(OUTS) <<- EOM
---
layout: default 
title: {title}
parent: Rules
---
EOM
cat $(SRCS) >> $(OUTS)
    """.format(title=src)
    ) for src in srcs]

    # Grouping files into single addressable target
    native.filegroup(
        name = "bzl_docs",
        srcs = [src+".md" for src in srcs],
        visibility = visibility
    )
