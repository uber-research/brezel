#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# STAGE: Install bazel
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ARG BASEIMAGE=ubuntu:18.04
FROM ${BASEIMAGE} AS bazel

# Install Basic Stuff
RUN apt-get update --quiet \
    && apt-get install --quiet --assume-yes --no-install-recommends \
    apt-utils \
    ca-certificates \
    build-essential \
    curl \
    gdb \
    git \
    gnupg2 \
    iputils-ping \
    lsb-release \
    pkg-config \
    psmisc \
    python \
    python3-distutils \
    ssh \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Bazel
ARG bazel_version
ENV BAZEL_VERSION=${bazel_version}
COPY scripts/install/install_bazel.sh /tmp/
RUN /tmp/install_bazel.sh ${BAZEL_VERSION}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# STAGE: Install other dependencies
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM bazel AS devel

# Install dev prerequisites
COPY scripts/install/install_prerequisites.sh /tmp/
RUN /tmp/install_prerequisites.sh

# Install Protobuf
COPY scripts/install/install_protobuf.sh /tmp/
ARG WITH_PROTOBUF=false
RUN ! ${WITH_PROTOBUF} || /tmp/install_protobuf.sh

# Install Docker CLI
COPY scripts/install/install_docker_cli.sh /tmp
ARG WITH_DOCKER=false
RUN ! ${WITH_DOCKER} || /tmp/install_docker_cli.sh

# Install Docker credential helper for GCR
COPY scripts/install/install_docker_credential_gcr.sh /tmp
ARG WITH_DOCKER_GCR=false
RUN ! ${WITH_DOCKER_GCR} || /tmp/install_docker_credential_gcr.sh

# Install Kubernetes CLI
COPY scripts/install/install_kubernetes_cli.sh /tmp
ARG WITH_KUBECTL=false
RUN if ${WITH_KUBECTL}; then \
        /tmp/install_kubernetes_cli.sh ;\
        export KREW_ROOT="/opt/krew" ;\
        export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" ;\
    fi

# Install Terraform CLI
COPY scripts/install/install_terraform.sh /tmp
ARG WITH_TERRAFORM=false
RUN ! ${WITH_TERRAFORM} || /tmp/install_terraform.sh

# Install Google Cloud Storage Command Line Tool
COPY scripts/install/install_gsutil.sh /tmp
ARG WITH_GSUTIL=false
RUN if ${WITH_GSUTIL}; then \
        /tmp/install_gsutil.sh ;\
        export PATH="/opt/gsutil:${PATH}" ;\
    fi

# Install Jekyll
COPY scripts/install/install_jekyll.sh /tmp
ARG WITH_JEKYLL=false
RUN ! ${WITH_JEKYLL} || /tmp/install_jekyll.sh

# Installing Opengl Dev prerequisites
COPY scripts/install/install_opengl_dev.sh /tmp/
ARG WITH_OPENGL=false
RUN ! ${WITH_OPENGL} || /tmp/install_opengl_dev.sh

# Installing OpenCv
COPY scripts/install/install_opencv.sh /tmp/
ARG WITH_OPENCV=false
RUN ! ${WITH_OPENCV} || /tmp/install_opencv.sh

# Install linters
COPY scripts/install/install_linters.sh /tmp
ARG WITH_LINTERS=false
RUN ! ${WITH_LINTERS} || /tmp/install_linters.sh

# Install Orca for Plotly static image export
COPY scripts/install/install_orca.sh /tmp/
ARG WITH_ORCA=false
RUN ! ${WITH_ORCA} || /tmp/install_orca.sh

# Install visualization tools
RUN apt-get update --quiet \
    && apt-get install --quiet --assume-yes --no-install-recommends \
    graphviz \
    tree \
    && rm -rf /var/lib/apt/lists/*

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# STAGE: Finalize user settings
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Create local user and setup groups
RUN useradd --create-home --shell /bin/bash ubrzl
ARG DOCKER_GID=127
RUN groupadd -g ${DOCKER_GID} docker && \ 
    usermod -aG docker,daemon ubrzl

# Install zsh
COPY scripts/install/install_zsh.sh /tmp
RUN /tmp/install_zsh.sh
COPY --chown=ubrzl:ubrzl config/shell/zshrc /home/ubrzl/.zshrc

# Init cache directories
RUN mkdir -p /var/cache/bazel/repo && chown -R ubrzl:ubrzl /var/cache/bazel
USER ubrzl
RUN mkdir -p ${HOME}/.cache
RUN ln -s /var/cache/bazel ${HOME}/.cache/bazel

# Add dev settings for in-docker Dev
COPY brezel/tools/.vimrc /home/ubrzl/.vimrc
RUN echo "source /etc/bash_completion.d/bazel">> ~/.bashrc
ENV LC_ALL "C.UTF-8"
ENV LANG "C.UTF-8"

# Add scripts for custom entrypoint
COPY scripts/system /system
COPY scripts/infra /system
