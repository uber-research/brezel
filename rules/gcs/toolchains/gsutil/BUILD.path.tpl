# Adapted from https://github.com/bazelbuild/rules_k8s/blob/master/toolchains/kubectl/BUILD.path.tpl
# SPDX-License-Identifier: Apache-2.0
"""
This BUILD file is auto-generated from toolchains/gsutil/BUILD.tpl
"""

package(default_visibility = ["//visibility:public"])

load("@brezel//rules/gcs/toolchains/gsutil:gsutil_toolchain.bzl", "gsutil_toolchain")

gsutil_toolchain(
    name = "toolchain",
    tool_path = "%{GSUTIL_TOOL}",
    boto_config = "%{BOTO_CONFIG}",
)
