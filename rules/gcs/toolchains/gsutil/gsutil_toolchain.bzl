# Adapted from https://github.com/bazelbuild/rules_k8s/blob/master/toolchains/kubectl/kubectl_toolchain.bzl
# SPDX-License-Identifier: Apache-2.0
"""
This module implements the gsutil toolchain rule.
"""

GsutilInfo = provider(
    doc = "Information about how to invoke the gsutil tool.",
    fields = {
        "tool_path": "Path to the gsutil executable",
        "tool_target": "A gsutil executable target downloaded.",
        "boto_config": "The .boto configuration with the credentials.",
    },
)

def _gsutil_toolchain_impl(ctx):
    if not ctx.attr.tool_path and not ctx.attr.tool_target:
        print("No gsutil tool was found or built, some targets might not work.")
    toolchain_info = platform_common.ToolchainInfo(
        gsutilinfo = GsutilInfo(
            tool_path = ctx.attr.tool_path,
            tool_target = ctx.attr.tool_target,
            boto_config = ctx.attr.boto_config,
        ),
    )
    return [toolchain_info]

gsutil_toolchain = rule(
    implementation = _gsutil_toolchain_impl,
    attrs = {
        "tool_path": attr.string(
            doc = "Absolute path to a pre-installed gsutil binary.",
            mandatory = False,
        ),
        "tool_target": attr.label(
            doc = "Target to build gsutil from source or a downloaded gsutil binary.",
            mandatory = False,
        ),
        "boto_config": attr.string(
            doc = "Absolute path to a .boto configuration file.",
            mandatory = False,
        )
    },
)
