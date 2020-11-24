load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def third_party_repositories():
    '''
    Where we specify the repositories for external libraries
    '''
    all_content = """filegroup(name = "all", srcs = glob(["**"]), visibility = ["//visibility:public"])"""

    # Eigen
    http_archive(
        name = "eigen",
        strip_prefix = "eigen-3.3.7",
        sha256 = "d56fbad95abf993f8af608484729e3d87ef611dd85b3380a8bad1d5cbc373a57",
        urls = [
            "https://gist.github.com/rpennec/e7c18a4f07c13b5a5aaf09f3473a42e2/raw/c76aa9cf55fb385f9a33acf1e6262e97d7a3166a/eigen-3.3.7.tar.gz",
            "https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.tar.gz"
        ],
        build_file = "@brezel//third_party:eigen.BUILD"
    )

    # Google Test
    git_repository(
        name = "gtest",
        remote = "https://github.com/google/googletest",
        commit = "703bd9caab50b139428cea1aaff9974ebee5742e",
        shallow_since = "1570114335 -0400",
    )

    # ScalaPB 0.10.2
    http_archive(
        name = "com_thesamet_scalapb",
        url = "https://github.com/scalapb/ScalaPB/archive/v0.10.2.zip",
        strip_prefix = "ScalaPB-0.10.2",
        sha256 = "28635c40220b78be2fbd8e1f0df044469de1f6dd3fa1a21941b54b75167a2f75",
        build_file = "@brezel//third_party:scalapb.BUILD"
    )
