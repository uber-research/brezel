# CC toolchain loads
load("@rules_foreign_cc//:workspace_definitions.bzl", "rules_foreign_cc_dependencies")

# Go toolchain loads
load("@io_bazel_rules_docker//go:image.bzl", docker_go_image_repos="repositories")

# Scala toolchain loads
load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")
load("@io_bazel_rules_scala//scala_proto:scala_proto.bzl", "scala_proto_repositories")
load("@io_bazel_rules_scala//scala_proto:toolchains.bzl", "scala_proto_register_toolchains")

# Python toolchain loads
load("@rules_python_external//:defs.bzl", "pip_install")
load("@io_bazel_rules_docker//python3:image.bzl", docker_py3_image_repos="repositories")

# NodeJS toolchain loads
load("@build_bazel_rules_nodejs//:index.bzl", "node_repositories")
load("@build_bazel_rules_nodejs//:index.bzl", "yarn_install")

# Docker toolchain loads
load("@brezel//rules:images.bzl", "setup_scala_images", "setup_python_images")
load("@io_bazel_rules_docker//repositories:pip_repositories.bzl", rules_docker_pip_deps="pip_deps")

# Kubernetes toolchain loads
load("@io_bazel_rules_k8s//k8s:k8s_go_deps.bzl", k8s_go_deps="deps")
load("@brezel_defaults//:gcp.bzl", "PROJECT")

# Gsutil toolchain loads
load("@brezel//rules/gcs/toolchains/gsutil:gsutil_configure.bzl", "gsutil_configure")

def setup_cc_toolchain():
    # Cmake foreign toolchain
    rules_foreign_cc_dependencies()

def setup_go_toolchain():
    # Go toolchain setup
    docker_go_image_repos()

def setup_scala_toolchain():
    scala_version = "2.12.10"
    # Scala toolchain setup
    scala_register_toolchains()
    scala_repositories((scala_version,
        {
            "scala_compiler": "cedc3b9c39d215a9a3ffc0cc75a1d784b51e9edc7f13051a1b4ad5ae22cfbc0c",
            "scala_library": "0a57044d10895f8d3dd66ad4286891f607169d948845ac51e17b4c1cf0ab569d",
            "scala_reflect": "56b609e1bab9144fb51525bfa01ccd72028154fc40a58685a1e9adcbe7835730"
        }
    ))
    # Proto toolchains for scala
    scala_proto_repositories(scala_version=scala_version)
    scala_proto_register_toolchains()

    # Docker repositories for scala
    setup_scala_images()

def setup_python_toolchain():
    # Python toolchain setup
    pip_install(
        name = "python3_deps",
        requirements = "@brezel//third_party/pip:requirements.txt",
    )

    pip_install(
        name = "python3_extra_deps",
        requirements = "@brezel//third_party/pip:extra-requirements.txt",
    )

    pip_install(
        name = "rules_proto_grpc_py3_deps",
        requirements = "@rules_proto_grpc//python:requirements.txt",
    )

    # Docker repositories for python
    setup_python_images()

def setup_docker_toolchain():
    rules_docker_pip_deps()

def setup_nodejs_toolchain():
    node_repositories(
        package_json = ["@brezel//third_party/npm:package.json"],
        node_version = "10.13.0",
        yarn_version = "1.5.1"
    )

    yarn_install(
        name = "npm",
        package_json = "@brezel//third_party/npm:package.json",
        yarn_lock = "@brezel//third_party/npm:yarn.lock",
        symlink_node_modules = False
    )

def setup_kubernetes_toolchain():
    k8s_go_deps()

def setup_gsutil_toolchain():
    native.register_toolchains(
        "@brezel//rules/gcs/toolchains/gsutil:gsutil_linux_toolchain",
        "@brezel//rules/gcs/toolchains/gsutil:gsutil_osx_toolchain",
        "@brezel//rules/gcs/toolchains/gsutil:gsutil_windows_toolchain",
    )
    gsutil_configure(
        name = "gcs_config",
        boto = "/secrets/%s-gsutil.boto" % PROJECT
    )

def setup_all_toolchains():
    '''
    Configuration steps for bazel toolchains
    '''
    setup_cc_toolchain()
    setup_go_toolchain()
    setup_scala_toolchain()
    setup_python_toolchain()
    setup_docker_toolchain()
    setup_kubernetes_toolchain()
    setup_nodejs_toolchain()
    setup_gsutil_toolchain()
