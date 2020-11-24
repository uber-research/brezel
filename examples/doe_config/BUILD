load("@io_bazel_rules_docker//go:image.bzl", "go_image")
load("@brezel//rules/doe:config_factory.bzl", "doe_config_param", "doe_config")
load("@brezel//rules/doe:gke.bzl", "doe_gke")
load("@brezel_defaults//:gcp.bzl", "REGISTRY", "BUCKET")
load("@brezel//rules/doc:md.bzl", "md_docs")

md_docs()

doe_config_param(
    name = "algo",
    values = ["ppo", "trpo", "ddpg"],
)

doe_config_param(
    name = "layer",
    values = ["[16, 16]", "[18, 18]"],
)

doe_config_param(
    name = "n_steps",
    naming = 'N{}',
    values = ["1000"],
)

doe_config(
    name = "config",
    template = "config.yaml.tpl",
    substitutions = {"%{PATH}": "/some/path"},
    params = [":algo", ":layer", ":n_steps"],
)

sh_test(
    name = "demo",
    srcs = ["demo.sh"],
    args = ["$(locations :config.files)"],
    data = [":config.files"],
)

go_image(
    name = "hello-img",
    srcs = ["hello.go"],
    data = [":config.files"],
)

doe_gke(
    name = "doe",
    experiment = "demo-doe-config",
    image = {REGISTRY+"/gke-doe-test/go-hello:latest": ":hello-img"},
    gcs_upload = {"/out": BUCKET+"/brezel_examples/doe_config/"},
    config = ":config",
    nodepool = "pool-small-experiments",
)
