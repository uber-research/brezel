workspace(
    name = "brezel"
)

# Defaults
load("//rules:defaults.bzl", "brezel_defaults")
brezel_defaults(srcs=["//config/infra/vars:gcp.bzl", "//config/infra/vars:gke.bzl"])

# Declaring remote repositories for third party libraries
load("//third_party:deps.bzl", "third_party_repositories")
third_party_repositories()

# Declaring remote repositories for rules
load("//third_party:rules.bzl", "rule_repositories")
rule_repositories()

# Repositories to fetch external dependencies of external rules
load("//third_party:rules_deps.bzl", "all_indirect_repositories")
all_indirect_repositories()

# Preparing toolchains 
load("//third_party/toolchains:prepare_toolchains.bzl", "prepare_all_toolchains")
prepare_all_toolchains()

# Configuring toolchains
load("//third_party/toolchains:toolchains.bzl", "setup_all_toolchains")
setup_all_toolchains()
