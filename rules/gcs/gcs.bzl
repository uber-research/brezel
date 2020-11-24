def _gcs_file_impl(ctx):
    gsutil_tool_info = ctx.toolchains["@brezel//rules/gcs/toolchains/gsutil:toolchain_type"].gsutilinfo
    gsutil_file = gsutil_tool_info.tool_path
    if gsutil_tool_info.tool_target:
        # [0] is the source file in the depset, [1] is the generated one
        gsutil_file = gsutil_tool_info.tool_target.files.to_list()[-1]

    out_file = ctx.actions.declare_file(ctx.label.name)
    uri = "{bucket}/{path}".format(bucket=ctx.attr.bucket.rstrip('/'), path=ctx.attr.file)
    ctx.actions.run(
        mnemonic = "GcsDownload",
        outputs = [out_file],
        executable = gsutil_file,
        arguments = ["cp", uri, out_file.path],
        env = {"BOTO_CONFIG": gsutil_tool_info.boto_config},
    )
    return [DefaultInfo(files = depset([out_file]))]

gcs_file = rule(
    attrs = {
        "bucket": attr.string(
            mandatory = True,
            doc = "The GCS bucket which contains the file.",
        ),
        "file": attr.string(
            mandatory = True,
            doc = "The file which we are downloading.",
        ),
        # This is required for gsutil_file to find .runfiles directory
        # There must be a better way.
        "_gsutil": attr.label(
            default = Label("@gsutil_exec//gsutil:cmd"),
            allow_files = True,
            executable = True,
            cfg = "host"
        )
    },
    implementation = _gcs_file_impl,
    toolchains=["@brezel//rules/gcs/toolchains/gsutil:toolchain_type"],
)


def _gcs_tar_impl(ctx):
    # prepare gsutil toolchain
    gsutil_tool_info = ctx.toolchains["@brezel//rules/gcs/toolchains/gsutil:toolchain_type"].gsutilinfo
    gsutil_file = gsutil_tool_info.tool_path
    if gsutil_tool_info.tool_target:
        # [0] is the source file in the depset, [1] is the generated one
        gsutil_file = gsutil_tool_info.tool_target.files.to_list()[-1]

    # run downloader
    tar = ctx.actions.declare_file("{}.tar.gz".format(ctx.label.name))
    checksum = ctx.attr.sha256
    uri = "{bucket}/{path}/".format(
        bucket=ctx.attr.bucket.rstrip('/'),
        path=ctx.attr.folder.rstrip('/')
    )
    ctx.actions.run(
        mnemonic = "GcsDownload",
        progress_message = "Downloading {}".format(uri),
        outputs = [tar],
        executable = ctx.executable._downloader,
        arguments = [tar.path, uri, gsutil_file.path, checksum],
        env = {"BOTO_CONFIG": gsutil_tool_info.boto_config},
        tools = [gsutil_file],
    )
    return [DefaultInfo(
        files = depset([tar]),
        runfiles = ctx.runfiles([tar]))
    ]


gcs_tar = rule(
    attrs = {
        "bucket": attr.string(
            mandatory = True,
            doc = "The GCS bucket which contains the file.",
        ),
        "folder": attr.string(
            mandatory = True,
            doc = "The folder we are downloading.",
        ),
        "sha256": attr.string(
            mandatory = False,
            doc = "The sha256 checksum of the archive.",
        ),
        "_downloader": attr.label(
            default = Label("@brezel//rules/gcs:tar_downloader"),
            executable = True,
            cfg = "host",
        ),
        # This is required for gsutil_file to find .runfiles directory
        # There must be a better way.
        "_gsutil": attr.label(
            default = Label("@gsutil_exec//gsutil:cmd"),
            allow_files = True,
            executable = True,
            cfg = "host"
        ),
    },
    implementation = _gcs_tar_impl,
    toolchains=["@brezel//rules/gcs/toolchains/gsutil:toolchain_type"],
)
