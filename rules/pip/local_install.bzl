_LIB_ALIAS = 'alias(name = "{}", actual = "//{}", visibility = ["//visibility:public"])\n'
_NUL_FILEGROUP = 'filegroup(name = "local_install", visibility = ["//visibility:public"])\n'
_ALL_FILEGROUP = 'filegroup(name = "{}", srcs = glob(["**/*"]), visibility = ["//visibility:public"])\n'


def _pip_local_install_impl(rctx):
    """Implementation of repository rule pip_local_install
    
    This function performs `pip install -e <path>` either directly in the local
    folder (if attribute local_intall is True) or first copies the folder's
    content inside bazel external folder and runs pip install there.

    Option `--target` was considered but it doesn't seems to be equivalent.
    """
    # Get location of the pip binary
    pip = rctx.attr.pip
    if '/' not in pip:
        pip = rctx.which(pip)
    if not pip:
        fail("pip3 not found")

    # Find out the absolute path on the system of the source folder.
    # This information is not directly available, that's why we need
    # a bazel file pointing at a file inside the directory (here the
    # manifest file).
    local_path = rctx.path(rctx.attr.manifest).dirname

    # The name of the folder. We will use it to name the bazel rule.
    project_name = local_path.basename

    # If local installation was requested, we just check that a BUILD
    # file exists in the folder. Otherwise we need to copy the folder
    # and create a BUILD file in it. We keep track of the installation
    # path in variable `project_path`.
    if rctx.attr.local_install:
        project_path = local_path
    else:
        project_path = rctx.path(project_name)
        # execute `cp`
        result = rctx.execute(
            ["cp", "-r", local_path, rctx.path('.')]
        )
        if result.return_code:
            fail("local_install failed: %s (%s)" % (result.stdout, result.stderr))
        # write BUILD file inside the installed package
        rctx.file(
            "{}/BUILD".format(project_name),
            _ALL_FILEGROUP.format(project_name)
        )

    # Performs `pip install`
    args = ["install", "-e", project_path]
    result = rctx.execute(
        [pip]+args,
        timeout = rctx.attr.timeout,
    )
    if result.return_code:
        fail("local_install failed: %s (%s)" % (result.stdout, result.stderr))

    # write main BUILD file with the aliases and rule `local_install`.
    rctx.file("BUILD", ''.join([_LIB_ALIAS.format(project_name, project_name), _NUL_FILEGROUP]))
    return

"""Define bazel repository rule `pip_local_install`.

Call this rule from your project WORKSPACE.
Option `configure` is enabled so that the user can easily force this rule to run
again with `bazel sync --configure`.
Option `local` is enabled to maximaze rebuild on folder change.
"""
pip_local_install = repository_rule(
    implementation = _pip_local_install_impl,
    local = True,
    configure = True,
    attrs = {
        "manifest": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "Label pointing at file `MANIFEST.in`. This is required to determine the path of the source folder.",
        ),
        "pip": attr.string(
            default = "pip3",
            doc = "The pip3 binary. Pass an absolute path if you don't want to use the default one.",
        ),
        "local_install": attr.bool(
            default = False,
            doc = "If enabled, pip install will be performed directly inside the local directory. Otherwise the folder will be copied inside bazel's sandbox before.",
        ),
        "timeout": attr.int(
            default = 600,
            doc = "Bazel timeout for running pip install",
        ),
    },
)
