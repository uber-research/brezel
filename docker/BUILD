load("@io_bazel_rules_docker//container:container.bzl", "container_image")
load("@brezel//rules:images.bzl", "extended_container_image")

container_image(
    name = "python3_base",
    base = "@python3_slim_base//image",
    symlinks = {
        "/usr/bin/python": "/usr/local/bin/python",
        "/usr/bin/python3": "/usr/local/bin/python3"
    },
    visibility = ["//visibility:public"]
)

container_image(
    name = "python3_gpu_gke_base",
    base = "@python3_slim_base//image",
    symlinks = {
        "/usr/bin/python": "/usr/local/bin/python",
        "/usr/bin/python3": "/usr/local/bin/python3"
    },
    env = {"LD_LIBRARY_PATH":"/usr/local/nvidia/lib64"},
    visibility = ["//visibility:public"]
)

container_image(
    name = "ubuntu18_base",
    base = "@ubuntu1804//:image",
    env = {
        "DEBIAN_FRONTEND": "noninteractive",
        "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    },
    visibility = ["//visibility:public"]
)

CMAKE_PACKAGES = [
    "apt-utils",
    "build-essential",
    "ca-certificates",
    "cmake",
    "curl",
    "git",
    "gnupg2",
    "make",
]

extended_container_image(
    name = "ubuntu18_cmake",
    base = ":ubuntu18_base.tar",
    packages = CMAKE_PACKAGES,
    visibility = ["//visibility:public"]
)
