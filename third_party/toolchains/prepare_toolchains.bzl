# Proto-related repos downloaded by indirect rules deps
load("@com_github_grpc_grpc//bazel:grpc_deps.bzl", "grpc_deps")
load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps="deps")
load("@ubuntu1804//:deps.bzl", ubuntu1804_deps="deps")
load("@rules_proto_grpc_py3_deps//:requirements.bzl", grpc_pip_install="pip_install")

def prepare_proto_toolchain():
    grpc_deps()

def prepare_python_toolchain():
    grpc_pip_install()

def prepare_docker_toolchain():
    container_deps()
    ubuntu1804_deps()

def prepare_minimal_toolchains():
    prepare_proto_toolchain()

def prepare_all_toolchains():
    prepare_proto_toolchain()
    prepare_python_toolchain()
    prepare_docker_toolchain()
