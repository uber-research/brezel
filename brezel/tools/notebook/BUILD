load(":image.bzl", "notebook_image")
load("@python3_deps//:requirements.bzl", "requirement", base_requirements="all_requirements")
load("@python3_extra_deps//:requirements.bzl", extra_requirement="requirement")

py_binary(
    name = "notebook",
    main = "jupyter.py",
    srcs = ["jupyter.py"],
    args = ["--notebook-dir", "/repo"],
    deps = [
        requirement("click"),
        requirement("numpy"),
        extra_requirement("notebook"),
        extra_requirement("pandas"),
    ],
)

notebook_image(
    name = "notebook-img",
    deps = base_requirements,
)

exports_files(
    srcs = ["jupyter.py"],
    visibility = ["//visibility:public"]
)
