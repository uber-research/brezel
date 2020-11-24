load("@bazel_toolchains//rules:gcs.bzl", "gcs_file")

_BUILD_GENRULE_TPL = """\
genrule(
    name = "{}_link",
    outs = ["{}"],
    srcs = ["{}"],
    cmd = "cp $< $@",
)
"""
_BUILD_HEADER = """\
package(default_visibility = ["//visibility:public"])
"""

def _register_gcs_files(file_list, bucket):
    """Register gcs_file rules

    
    Args:
      file_list: The list of the file objects `(name, path, hash)`.
      bucket: The bucket address.
    """
    [gcs_file(
        name = "download_{}".format(name),
        bucket = bucket,
        downloaded_file_path = name,
        file = path,
        sha256 = sha256,
    ) for (name, path, sha256) in file_list]

def _gcs_file_label(data):
    """Return the label created by the `gcs_file` rule."""
    return Label("@download_{}//file".format(data))

def _gcs_bucket_build_file_impl(rctx):
    """Implementation of _gcs_bucket_build_file
    https://docs.bazel.build/versions/master/skylark/lib/repository_ctx.html
    """
    build_content = _BUILD_HEADER + "\n".join([
        _BUILD_GENRULE_TPL.format(k, k, _gcs_file_label(k))
        for k in rctx.attr.objects.keys()
    ]) + "\n" + 'filegroup(name="{}", srcs=["{}"])'.format("all", '", "'.join([
        str(_gcs_file_label(k)) for k in rctx.attr.objects.keys()
    ]))
    rctx.file("BUILD", build_content)
    for k in rctx.attr.objects.keys():
        rctx.symlink('../download_{}/file/{}'.format(k,k), rctx.path(k))

"""Repository Rule: _gcs_bucket_build_file
https://docs.bazel.build/versions/master/skylark/repository_rules.html
Generate the BUILD file containing the definition of the `filegroup` rules
associated with the `gcs_file` rules.
The generated target have label `@<name>//:<file>`
"""
_gcs_bucket_build_file = repository_rule(
    implementation = _gcs_bucket_build_file_impl,
    attrs = {
        "objects": attr.string_list_dict(
            allow_empty = False,
            mandatory = True,
        ),
        "bucket": attr.string(
            mandatory = True,
        ),
    },
)

"""Register objects from GCS bucket"""
def gcs_bucket_download(name, data_file_list, bucket, **kwargs):
    """Download multiple files from a GCS bucket.

    Args:
      name: A unique name for this rule.
        
        Downloaded files will be available at `@<name>//:<filename>`.
      data_file_list: The list of the files to be downloaded from the bucket

        Expected list format: `[(filename, path, hash), ...]`
        where `path` is the location of the file in the bucket and `hash` is
        the sha256sum of the file. Label `@<name>//:<filename>` is created.
      bucket: The address of the bucket.
    """
    _register_gcs_files(data_file_list, bucket)
    _gcs_bucket_build_file(
        name = name,
        bucket = bucket,
        objects = {n: [p, h] for (n,p,h) in data_file_list},
        **kwargs
    )
