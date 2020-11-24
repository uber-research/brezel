def _defaults_impl(rctx):
    rctx.file("BUILD", """
exports_files(glob(["**/*.bzl"]))       
    """)

    # include all srcs at the root of the repository
    for src in rctx.attr.srcs:
        rctx.symlink(src, src.name)

    # create file gcp.bzl except if already provided in srcs
    if "gcp.bzl" in [src.name for src in rctx.attr.srcs]:
        return
    rctx.file("gcp.bzl", """
PROJECT = "{project}"
CLUSTER = "{cluster}"
BUCKET = "{bucket}"
REGISTRY = "{registry}"
""".format(
        cluster = rctx.attr.gcp_cluster,
        project = rctx.attr.gcp_project,
        bucket = rctx.attr.gcp_bucket,
        registry = rctx.attr.gcp_registry,
    ))


"""Define `brezel_defaults`.

Call this rule from your project WORKSPACE.
"""
_defaults = repository_rule(
    implementation = _defaults_impl,
    local = True,
    attrs = {
        "srcs": attr.label_list(allow_files=[".bzl"]),
        "gcp_project": attr.string(),
        "gcp_cluster": attr.string(),
        "gcp_bucket": attr.string(),
        "gcp_registry": attr.string(),
    }
)

def brezel_defaults(**kwargs):
    _defaults(name="brezel_defaults", **kwargs)
