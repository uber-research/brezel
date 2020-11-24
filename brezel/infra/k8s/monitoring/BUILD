load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_binary")

nodejs_binary(
    name = "dashboard",
    data = [
      "@npm//blessed-contrib",
      "@npm//blessed",
      "@npm//kubernetes-client"
    ],
    entry_point = ":k8smon.js",
)
