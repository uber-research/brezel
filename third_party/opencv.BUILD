cc_library(
    name = "lib",
    hdrs = glob([
        "include/opencv4/opencv2/**/*.hpp",
        "include/opencv4/opencv2/**/*.h",
    ]),
    srcs = glob(["lib/libopencv_*.so.4.4"]),
    includes = ["include/opencv4"],
    visibility = ["//visibility:public"]
)
