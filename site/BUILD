load("@brezel//rules/doc:jekyll.bzl", "jekyll_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load(":list.bzl", "MD_DOCS", "PY_DOCS", "BZL_DOCS")

pkg_tar(name = "jekyll_srcs_tar", srcs = glob(["**/*"], exclude = ["BUILD"]))
pkg_tar(name = "repo_docs", srcs = MD_DOCS, strip_prefix = ".")
pkg_tar(name = "libs_docs", srcs = PY_DOCS, strip_prefix = ".")
pkg_tar(name = "bzl_docs", srcs = BZL_DOCS, strip_prefix = ".") 

jekyll_build(
    name = "site",
    srcs = [
        ":jekyll_srcs_tar",
        ":repo_docs", ":libs_docs", ":bzl_docs"
    ]
)

