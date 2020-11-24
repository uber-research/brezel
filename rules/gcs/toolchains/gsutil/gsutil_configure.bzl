# Adapted from https://github.com/bazelbuild/rules_k8s/blob/master/toolchains/kubectl/kubectl_configure.bzl
# SPDX-License-Identifier: Apache-2.0
"""
Defines a repository rule for configuring the gsutil tool.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


def _check_boto_config(repository_ctx):
    boto = repository_ctx.attr.boto_config
    cat_boto = repository_ctx.execute(["cat", boto])
    if cat_boto.return_code != 0:
        print("""WARNING
    Could not read from '{}'.
    GCS rules using gsutil won't (most likely) work.
    Save the appropriate files in BREZEL_HOME/secrets
    and try again with `make run-secrets`.
        """.format(boto))


def _impl(repository_ctx):
    substitutions = None
    if repository_ctx.attr.download_release:
        gsutil_target = "@gsutil_exec//gsutil:cmd"
        substitutions = {"%{GSUTIL_TARGET}": gsutil_target}
        template = Label("@brezel//rules/gcs/toolchains/gsutil:BUILD.target.tpl")
    elif repository_ctx.attr.gsutil_path != None:
        substitutions = {"%{GSUTIL_TARGET}": "%s" % repository_ctx.attr.gsutil_path}
        template = Label("@brezel//rules/gcs/toolchains/gsutil:BUILD.target.tpl")
    else:
        gsutil_tool_path = repository_ctx.which("gsutil") or ""
        substitutions = {"%{GSUTIL_TOOL}": "%s" % gsutil_tool_path}
        template = Label("@brezel//rules/gcs/toolchains/gsutil:BUILD.path.tpl")

    if repository_ctx.attr.boto_config:
        boto = repository_ctx.attr.boto_config
        _check_boto_config(repository_ctx)
        substitutions = dict({"%{BOTO_CONFIG}": boto}, **substitutions)

    repository_ctx.template(
        "BUILD",
        template,
        substitutions,
        False,
    )

_gsutil_configure = repository_rule(
    implementation = _impl,
    attrs = {
        "download_release": attr.bool(
            doc = "Optional. Set to true to download gsutil from github.",
            default = False,
            mandatory = False,
        ),
        "gsutil_path": attr.label(
            allow_single_file = True,
            mandatory = False,
            doc = "Optional. Path to a prebuilt custom gsutil binary file or" +
                  " label. Can't be used together with attribute 'download_release'.",
        ),
        "boto_config": attr.string(
            doc = "Optinal. Path to a boto configuration file.",
        ),
    },
)

def _download_gsutil_impl(rctx):
    # Download tarball
    rctx.download_and_extract(
        url = "https://storage.googleapis.com/pub/gsutil.tar.gz",
        sha256 = "",
        output = ".",
        type = "tar.gz",
    )

    # Add BUILD file
    rctx.file("gsutil/BUILD", """
py_library(
    name = "gslib",
    srcs = glob(["gslib/**/*.py"]),
)

py_binary(
    name = "cmd",
    main = "gsutil.py",
    srcs = ["gsutil.py"],
    deps = [":gslib"],
    visibility = ["//visibility:public"]
)
""", executable=False)

download_gsutil = repository_rule(
    implementation = _download_gsutil_impl
)


def gsutil_configure(name = "gcs_config", boto=None, **kwargs):
    """Creates an external repository with a configured gsutil_toolchain target.
    """
    if "release" in kwargs and "gsutil_path" in kwargs:
        fail("Attributes 'build_srcs' and 'gsutil_path' can't be specified at" +
             " the same time")
    if "release" in kwargs and kwargs["release"]:
        gsutil_tag = kwargs["release"]
        gsutil_sha = kwargs["sha256"] if "sha256" in kwargs else ''
    else:
        download_gsutil(name = "gsutil_exec")

    _gsutil_configure(
        name = name,
        gsutil_path = kwargs["gsutil_path"] if "gsutil_path" in kwargs else None,
        download_release = "gsutil_path" not in kwargs,
        boto_config = boto,
    )
