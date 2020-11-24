load("@python3_deps//:requirements.bzl", "requirement")

exports_files([
    "jekyll_build.sh.tpl",
    "pydoc-markdown.yml"
])

PYDOC_MAIN = requirement("pydoc_markdown")+":pydoc_markdown/main.py"

py_binary(
	name = "pydoc_bin",
	main = PYDOC_MAIN,
	srcs = [PYDOC_MAIN],
	deps = [
		requirement("pydoc-markdown"),
		requirement("setuptools")
	],
    visibility = ["//visibility:public"]
)

