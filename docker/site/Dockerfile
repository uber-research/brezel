ARG BASEIMAGE=ubuntu:18.04
FROM ${BASEIMAGE}
USER root

ENV DEBIAN_FRONTEND=noninteractive

COPY scripts/install/install_jekyll.sh /tmp/install_jekyll.sh
RUN /tmp/install_jekyll.sh
