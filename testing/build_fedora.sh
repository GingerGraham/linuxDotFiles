#!/bin/bash

# Expect 2 arguments passed to the script and assign them to the variables DISTRO and DISTRO_VERSION in that order

DISTRO=${1}
DISTRO_VERSION=${2}

echo "[DEBUG] Building Dockerfile for ${DISTRO}:${DISTRO_VERSION}"

cat << EOF > dockerfile
FROM ${DISTRO}:${DISTRO_VERSION}

RUN groupadd -g 1000 test-user && useradd -u 1000 -g test-user -s /bin/bash -m test-user

# Install dependencies
RUN dnf install -y \
    git \
    curl \
    wget \
    vim \
    zsh \
    tmux \
    python3 \
    python3-pip \
    golang

# Set the working directory
WORKDIR /home/test-user

# Set the user
USER test-user

EOF