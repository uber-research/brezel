# Adapted from https://github.com/bazelbuild/rules_k8s/blob/master/toolchains/kubectl/BUILD
# SPDX-License-Identifier: Apache-2.0
load(":gsutil_toolchain.bzl", "gsutil_toolchain")

package(default_visibility = ["//visibility:private"])

# gsutil toolchain type
toolchain_type(name = "toolchain_type")

# Default gsutil toolchain that expects the 'gsutil' executable
# to be in the PATH
gsutil_toolchain(
    name = "default_gsutil",
    tool_path = "gsutil",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "gsutil_linux_toolchain",
    target_compatible_with = [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
    ],
    toolchain = "@gcs_config//:toolchain",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "gsutil_osx_toolchain",
    target_compatible_with = [
        "@bazel_tools//platforms:osx",
        "@bazel_tools//platforms:x86_64",
    ],
    toolchain = "@gcs_config//:toolchain",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "gsutil_windows_toolchain",
    target_compatible_with = [
        "@bazel_tools//platforms:windows",
        "@bazel_tools//platforms:x86_64",
    ],
    toolchain = "@gcs_config//:toolchain",
    toolchain_type = ":toolchain_type",
)
