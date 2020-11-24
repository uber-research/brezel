load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def skylib_rule_repositories():
    # bazel-skylib 0.8.0 released 2019.03.20
    # CONFLICT WITH rules_proto_grpc ?
    skylib_version = "0.8.0"
    skylib_version_sha256 = "2ef429f5d7ce7111263289644d233707dba35e39696377ebab8b0bc701f7818e"
    http_archive(
        name = "bazel_skylib",
        type = "tar.gz",
        url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{}/bazel-skylib.{}.tar.gz".format(skylib_version, skylib_version),
        sha256 = skylib_version_sha256,
    )

def stardoc_rule_repositories():
    # stardoc 0.4.0 released 2019.10.14
    git_repository(
        name = "io_bazel_stardoc",
        remote = "https://github.com/bazelbuild/stardoc.git",
        commit = "4378e9b6bb2831de7143580594782f538f461180",
        shallow_since = "1570829166 -0400",
    )

def bazel_toolchains_repositories():
    # bazel-toolchains 3.2.0 released 2020.05.28
    version = '3.2.0'
    http_archive(
        name = "bazel_toolchains",
        sha256 = "db48eed61552e25d36fe051a65d2a329cc0fb08442627e8f13960c5ab087a44e",
        strip_prefix = "bazel-toolchains-{v}".format(v=version),
        urls = [
            "https://github.com/bazelbuild/bazel-toolchains/releases/download/{v}/bazel-toolchains-{v}.tar.gz".format(v=version),
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/releases/download/{v}/bazel-toolchains-{v}.tar.gz".format(v=version),
        ],
    )

def scala_rule_repositories():
    # rules_scala released 2020.03.07
    rules_scala_version = "0bb4bcb38359707157b823c2b0e7ad2370c90d8d"
    rules_scala_version_sha256 = "6be7a3e4a174590c069f502217a05437caf32ccaaea8ceb16d338f3af292c016"
    http_archive(
        name = "io_bazel_rules_scala",
        strip_prefix = "rules_scala-{}".format(rules_scala_version),
        type = "zip",
        url = "https://github.com/bazelbuild/rules_scala/archive/{}.zip".format(rules_scala_version),
        sha256 = rules_scala_version_sha256,
    )

def python_rule_repositories():
    # rules_python released 2020.08.03
    version = "e3df8bcf0f675d20aaf752c8ba32a0259dd79996"
    version_sha256 = "55b2a39c703a2dd964345ec84f3752d4137db5cf02d5a241ebaecf16bae259ec"
    http_archive(
        name = "rules_python",
        url = "https://github.com/bazelbuild/rules_python/archive/{}.zip".format(version),
        strip_prefix = "rules_python-{}".format(version),
        sha256 = version_sha256,
        type = "zip",
    )

def python_external_rule_repositories():
    # rules_python_external released 2020.07.09
    # Python rules to handle transitive external deps
    # See this PR https://github.com/bazelbuild/rules_python/pull/198
    version = "2c78da5b5beb78c4a96b8b4d84e9c34de8178efb"
    version_sha256 = "30987e33c0b00ef75d11dec756db6a5d57ccd4085525f8888d5237ef798f8d16"
    http_archive(
        name = "rules_python_external",
        url = "https://github.com/dillon-giacoppo/rules_python_external/archive/{}.zip".format(version),
        strip_prefix = "rules_python_external-{}".format(version),
        sha256 = version_sha256,
        type = "zip",
    )

def nodejs_rule_repositories():
    # rules_nodejs 1.7.0 released 2020.05.29
    version = "1.7.0"
    http_archive(
        name = "build_bazel_rules_nodejs",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/{v}/rules_nodejs-{v}.tar.gz".format(v=version)],
        sha256 = "84abf7ac4234a70924628baa9a73a5a5cbad944c4358cf9abdb4aab29c9a5b77"
    )

def proto_rule_repositories():
    # google protobuf 3.10.0 released 2019.10.03
    protobuf_version = "3.10.0"
    protobuf_version_sha256 = "758249b537abba2f21ebc2d02555bf080917f0f2f88f4cbe2903e0e28c4187ed"
    http_archive(
        name = "com_google_protobuf",
        url = "https://github.com/protocolbuffers/protobuf/archive/v{}.tar.gz".format(protobuf_version),
        strip_prefix = "protobuf-{}".format(protobuf_version),
        sha256 = protobuf_version_sha256,
    )

    # rules_proto_grpc 1.0.1
    http_archive(
        name = "rules_proto_grpc",
        urls = ["https://github.com/rules-proto-grpc/rules_proto_grpc/archive/1.0.1.tar.gz"],
        sha256 = "497225bb586e8f587e139c55b0f015e93bdddfd81902985ce24623528dbe31ab",
        strip_prefix = "rules_proto_grpc-1.0.1",
    )

def docker_rule_repositories():
    # rules_docker 0.14.4 released 2020.07.08
    rules_docker_version = "0.14.4"
    rules_docker_version_sha256 = "4521794f0fba2e20f3bf15846ab5e01d5332e587e9ce81629c7f96c793bb7036"
    http_archive(
        name = "io_bazel_rules_docker",
        sha256 = rules_docker_version_sha256,
        strip_prefix = "rules_docker-{}".format(rules_docker_version),
        urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v{tag}/rules_docker-v{tag}.tar.gz".format(tag=rules_docker_version)],
    )

def cmake_external_repositories():
    # rules_foreign_cc released 2020.07.13
    git_repository(
        name = "rules_foreign_cc",
        remote = "https://github.com/bazelbuild/rules_foreign_cc.git",
        commit = "9eb30f8c5a214799b73707666ca49e7b7a35978f",
        shallow_since = "1594651263 +0200",
    )

def google_container_repositories():
    # base-images-docker released 2020.08.17
    version = "ff71409b503b6fea42508af96efea07bf51f1272"
    version_sha256 = "f4374361ae4d46c9a3cf6c6e1b96b508e3bb905c79de62bb4d05bd39fd8a7c0e"
    http_archive(
        name = "ubuntu1804",
        strip_prefix = "base-images-docker-{}/ubuntu1804".format(version),
        urls = ["https://github.com/GoogleContainerTools/base-images-docker/archive/{}.tar.gz".format(version)],
        sha256 = version_sha256,
    )

def kubernetes_rule_repositories():
    # rules_k8s 0.4 released 2020.01.23
    # patched for stardoc
    version = "v0.4"
    http_archive(
        name = "io_bazel_rules_k8s",
        sha256 = "d91aeb17bbc619e649f8d32b65d9a8327e5404f451be196990e13f5b7e2d17bb",
        strip_prefix = "rules_k8s-{}".format(version[1:]),
        urls = ["https://github.com/bazelbuild/rules_k8s/releases/download/{v}/rules_k8s-{v}.tar.gz".format(v=version)],
        patch_cmds = ["""echo 'exports_files(["object.bzl"])' >> k8s/BUILD"""],
    )


def rule_repositories():
    """Download external rules.

    Call this function in your project WORKSPACE to declare the remote repositories
    for standard bazel rules. Must be call before all_indirect_repositories().

    Already defined repository rules will be skipped. It means that you can overwrite
    brezel choices by declaring them before calling rule_repositories().
    """

    # gather repository rules that already defined in the WORKSPACE.
    excludes = native.existing_rules().keys()

    if "com_google_protobuf" not in excludes:
        proto_rule_repositories()
        native.new_local_repository(
            name = "protobuf",
            path = "/usr",
            build_file = "@brezel//third_party:protobuf.BUILD",
        )

    if "io_bazel_stardoc" not in excludes:
        stardoc_rule_repositories()

    if "bazel_toolchains" not in excludes:
        bazel_toolchains_repositories()

    if "io_bazel_rules_scala" not in excludes:
        scala_rule_repositories()

    if "rules_python" not in excludes:
        python_rule_repositories()
        python_external_rule_repositories()

    if "build_bazel_rules_nodejs" not in excludes:
        nodejs_rule_repositories()

    if "rules_foreign_cc" not in excludes:
        cmake_external_repositories()

    if "io_bazel_rules_docker" not in excludes:
        docker_rule_repositories()
        google_container_repositories()

    if "io_bazel_rules_k8s" not in excludes:
        kubernetes_rule_repositories()

    # OpenGL rules
    native.new_local_repository(
        name = "opengl",
        path = "/usr",
        build_file = "@brezel//third_party:opengl.BUILD"
    )

    # OpenCV rules
    native.new_local_repository(
        name = "opencv",
        path = "/usr/local",
        build_file = "@brezel//third_party:opencv.BUILD"
    )
