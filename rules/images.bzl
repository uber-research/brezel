load("@io_bazel_rules_docker//container:container.bzl", "container_pull")
load("@io_bazel_rules_docker//container:container.bzl", "container_image")
load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs")
load("@io_bazel_rules_docker//docker/package_managers:install_pkgs.bzl", "install_pkgs")
load("@io_bazel_rules_docker//docker/util:run.bzl", "container_run_and_extract")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

# Load image repositories
load("@io_bazel_rules_docker//scala:image.bzl", docker_scala_image_repos="repositories")
load("@io_bazel_rules_docker//python3:image.bzl", docker_py3_image_repos="repositories")


def setup_scala_images():
    docker_scala_image_repos()


def pull_python_images():
    container_pull(
        name = "python3_slim_base",
        registry = "index.docker.io",
        repository = "python",
        tag = "3.6.10-slim-buster",
        digest = "sha256:f6383806178accdc1a321058e63c65081f29c5eb27488c5abba1e8698ebdbea9"
    )


def setup_python_images():
    docker_py3_image_repos()
    pull_python_images()


def extended_container_image(name, base, packages, **kwargs):
    """Create docker image with additional apt packages installed

    This macro simplifies the creation of docker images with apt packages
    pre-installed.

    Arguments:
        name: A unique name for the docker image.
        base: The base image on top of which the packages are installed.
        packages: The list of the aptitude packages to install.
        kwargs: Remaining arguments are passed to container_image.
    """
    download_pkgs(
        name = "{}__pkgs".format(name),
        image_tar = base,
        packages = packages,
    )

    install_pkgs(
        name = "{}__pkgs_image".format(name),
        image_tar = base,
        installables_tar = ":{}__pkgs.tar".format(name),
        installation_cleanup_commands = "rm -rf /var/lib/apt/lists/*",
        output_image_name = "{}__pkgs_image".format(name),
    )

    container_image(
        name = name,
        base = ":{}__pkgs_image.tar".format(name),
        **kwargs,
    )


def extended_python_image(name, packages, base="@python3_slim_base//image", **kwargs):
    extended_container_image(
        name = name,
        base = base,
        packages = packages,
        symlinks = {
            "/usr/bin/python": "/usr/local/bin/python",
            "/usr/bin/python3": "/usr/local/bin/python3"
        },
        **kwargs,
    )


def container_tar(name, commands, base="@ubuntu1804//:image.tar", extract="/usr/local", **kwargs):
    """Create tarball by running commands in a container

    This macro simplifies the usage of container_run_and_extract for the special
    case that you want to build a github project with configure/cmake/make.

    Arguments:
        name: A unique name for the docker image.
        commands: The list of the commands to run in the container.
        base: The base image on top of which the commands are run.
        extract: The directory to archive after the commands have terminated.
        kwargs: Remaining arguments are passed to pkg_tar.
    """
    container_run_and_extract(
        name = "{}_run_and_extract".format(name),
        extract_file = "/build.tar.gz",
        commands = commands + ["tar czf /build.tar.gz {out}".format(out=extract)],
        image = base,
    )
    pkg_tar(
        name = name,
        deps = ["{}_run_and_extract/build.tar.gz".format(name)],
        **kwargs,
    )


def container_make_tar(name, url, version="master", make_commands=["cmake ..", "make -j4", "make install"], base="@brezel//docker:ubuntu18_cmake.tar", **kwargs):
    """Create tarball by cloning and building a git repository

    This macro specializes container_tar by simplifying the classic `git clone` + `cmake` + `make` +` make install`.

    Arguments:
        name: A unique name for the docker image.
        url: The url of the git repository (usually "https://github.com/...")
        version: The version to checkout before running the commands.
        make_commands: The commands to build the downloaded project.
        base: The base image on top of which the commands are run.
        kwargs: Remaining arguments are passed to container_tar.
    """
    container_tar(
        name = name,
        commands = [
            "git clone {} /repository".format(url),
            "mkdir -p /repository/build",
            "cd /repository/build",
            "git checkout {}".format(version),
        ] + make_commands,
        base = base,
        **kwargs,
    )
