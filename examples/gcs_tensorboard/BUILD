load("@brezel//rules/gcs:gcs.bzl", "gcs_tar")
load("@brezel//rules/ml:tensorboard.bzl", "ml_tensorboard")
load("@brezel_defaults//:gcp.bzl", "BUCKET")

gcs_tar(
    name = "tblog",
    bucket = BUCKET,
    folder = "experiments/test_tensorboard/",
)

ml_tensorboard(
    name = "tb",
    data = [":tblog"],
)
