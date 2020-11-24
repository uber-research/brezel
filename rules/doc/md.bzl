def md_docs(srcs = [], visibility = ["@brezel//site:__pkg__"]):
    native.filegroup(
        name = "md_docs",
        srcs = srcs if len(srcs) > 0 else native.glob(["**/*.md"]),
        visibility = visibility
     )
