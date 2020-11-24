load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
load("@rules_proto_grpc//:repositories.bzl", "rules_proto_grpc_toolchains", "rules_proto_grpc_repos")
load("@rules_proto_grpc//cpp:repositories.bzl", proto_cpp_repos="cpp_repos")
load("@rules_proto_grpc//python:repositories.bzl", proto_python_repos="python_repos")

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

load("@rules_python_external//:repositories.bzl", "rules_python_external_dependencies")
load("@rules_python//python:pip.bzl", "pip_repositories")
load("@rules_python//python:pip.bzl", "pip_import")

load("@io_bazel_rules_docker//repositories:repositories.bzl", container_repositories="repositories")
load("@io_bazel_rules_k8s//k8s:k8s.bzl", "k8s_repositories")

def proto_repositories():
    protobuf_deps()
    rules_proto_grpc_toolchains()
    rules_proto_grpc_repos()
    proto_cpp_repos()

def docker_repositories():
    container_repositories()

def kubernetes_repositories():
    k8s_repositories()

def python_repositories():
    proto_python_repos()
    rules_python_external_dependencies()
    grpc_python_repositories()

def grpc_python_repositories():
    # Sadly we cannot use rules_python_external for this
    # As @rules_proto_grpc_py3_deps_pypi__grpclib_0_3_1//:pkg
    # is hardcoded in @rules_proto_grpc//python:python_grpc_library.bzl
    pip_repositories()
    pip_import(
        name = "rules_proto_grpc_py3_deps",
        python_interpreter = "python3",
        requirements = "@rules_proto_grpc//python:requirements.txt",
    )

def all_indirect_repositories():
    # Docker needs to be first here (Unclear why)
    docker_repositories()
    proto_repositories()
    stardoc_repositories()
    python_repositories()
    kubernetes_repositories()
