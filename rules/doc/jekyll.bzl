# Adapted from https://github.com/bazelbuild/bazel/blob/3.7.0/scripts/docs/jekyll.bzl
"""Quick rule to build a Jekyll site."""


def _impl(ctx):
    """Quick and non-hermetic rule to build a Jekyll site."""
    source = ctx.actions.declare_directory(ctx.attr.name + "-srcs")
    output = ctx.actions.declare_directory(ctx.attr.name + "-build")

    ctx.actions.run_shell(
        inputs = ctx.files.srcs,
        outputs = [source],
        command = ("mkdir -p %s\n" % (source.path)) +
                  "\n".join([
                      "tar xf %s -C %s" % (src.path, source.path)
                      for src in ctx.files.srcs
                  ]),
    )
    ctx.actions.run(
        inputs = [source],
        outputs = [output],
        executable = "jekyll",
        use_default_shell_env = True,
        arguments = ["build", "-q", "-s", source.path, "-d", output.path],
    )
    ctx.actions.run(
        inputs = [output],
        outputs = [ctx.outputs.out],
        executable = "tar",
        arguments = ["cf", ctx.outputs.out.path, "-C", output.path, "."],
    )

    ctx.actions.expand_template(
        template = ctx.file._jekyll_build_tpl,
        output = ctx.outputs.executable,
        substitutions = {
            "%{workspace_name}": ctx.workspace_name,
            "%{source_dir}": source.short_path,
            "%{prod_dir}": output.short_path,
        },
        is_executable = True,
    )


    return [DefaultInfo(runfiles = ctx.runfiles(files = [source, output]))]

jekyll_build = rule(
    implementation = _impl,
    executable = True,
    attrs = {
        "srcs": attr.label_list(allow_empty = False),
        "_jekyll_build_tpl": attr.label(
            default = ":jekyll_build.sh.tpl",
            allow_single_file = True,
        ),
    },
    outputs = {"out": "%{name}.tar"},
)
