load("@python3_deps//:requirements.bzl", "requirement")
load("@io_bazel_rules_docker//python3:image.bzl", "py3_image")
load("@brezel//rules/doe:gke.bzl", "doe_gke")
load("@brezel_defaults//:gcp.bzl", "REGISTRY", "BUCKET")
load("@brezel//rules/doc:md.bzl", "md_docs")

md_docs()

LIBS = [
    requirement('numpy'),
    requirement('click'),
]

py3_image(
    name = "test_img",
    main = "main.py",
    srcs = ["main.py"],
    deps = LIBS + ["@brezel//brezel/infra/doe:remote"],
    base = "@brezel//docker:python3_base",
)

py_binary(
    name = "test_local",
    main = "main.py",
    srcs = ["main.py"],
    data = [":data.txt"],
    deps = LIBS + ["@brezel//brezel/infra/doe:local"],
    args = ["--input-dir", "examples/gke_doe"],
)

doe_gke(
    name = "test-exp",
    image = {REGISTRY+"/gke-doe-test:dev": ":test_img"},
    matrix = ":test_doe.mat",
    nodepool = "pool-small-experiments",
    gcs_upload = {"/tmp": BUCKET+"/experiments/monorepo_gke_doe_example/results/"},
    gcs_download = {BUCKET+"/experiments/monorepo_gke_doe_example/inputs/": "/data"},
)
