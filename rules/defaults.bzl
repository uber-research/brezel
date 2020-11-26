_GCP_BZL_TEMPLATE = """
PROJECT = "{project}"
CLUSTER = "{cluster}"
BUCKET = "{bucket}"
REGISTRY = "{registry}"
"""

_INFRA_GCP_BUILD_TEMPLATE = """
exports_files(glob(["*"]))
"""

_INFRA_GCP_INI_TEMPLATE = """
[AUTH]
SERVICE_ACCOUNT_FILE = {sa_file}
"""

def _defaults_impl(rctx):
    rctx.file("BUILD", """
exports_files(glob(["**/*.bzl"]))       
    """)

    # include all srcs at the root of the repository
    for src in rctx.attr.srcs:
        rctx.symlink(src, src.name)

    # create file gcp.bzl except if already provided in srcs
    if "gcp.bzl" not in [src.name for src in rctx.attr.srcs]:
        rctx.file("gcp.bzl", _GCP_BZL_TEMPLATE.format(
            cluster = rctx.attr.gcp_cluster,
            project = rctx.attr.gcp_project,
            bucket = rctx.attr.gcp_bucket,
            registry = rctx.attr.gcp_registry,
        ))

    # regroup gcp infra settings in python library
    rctx.file("infra/BUILD",
        _INFRA_GCP_BUILD_TEMPLATE
    )
    rctx.file("infra/gcp.ini",
        _INFRA_GCP_INI_TEMPLATE.format(sa_file=rctx.attr.bucket_service_account)
    )

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
        "bucket_service_account": attr.string(default="/secrets/bucket-downloader-service-account.json"),
    }
)

def brezel_defaults(**kwargs):
    _defaults(name="brezel_defaults", **kwargs)
