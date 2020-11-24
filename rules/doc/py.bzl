load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

PYDOC_BIN = "@brezel//rules/doc:pydoc_bin"
PYDOC_CONFIG = "@brezel//rules/doc:pydoc-markdown.yml"

def py_docs(srcs, visibility = ["@brezel//site:__pkg__"]):
    # Creating one .md file per source python file
    [native.genrule(
        name = "gen_pydoc/{}".format(src),
        srcs = [src],
        outs = ["{}.md".format(src)],
        tools = [PYDOC_BIN, PYDOC_CONFIG],
        cmd = """
MODULE_PATH=$$(dirname $(SRCS))
MODULE=$$(basename $(SRCS) .py)
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
cat > $(OUTS) <<- EOM
---
layout: default
title: {title}
parent: Libraries
---
EOM
$(location {pydoc_bin}) -I $$MODULE_PATH -m $$MODULE >> $(OUTS)
        """.format(title=src, pydoc_bin=PYDOC_BIN, pydoc_config=PYDOC_CONFIG)
    ) for src in srcs]

    # Grouping the .md files to be addressable with a single label
    native.filegroup(
        name = "py_docs",
        srcs = [":{}.md".format(src) for src in srcs],
        visibility = visibility
    )
