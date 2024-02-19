#!/bin/bash

# Expect 2 arguments passed to the script and assign them to the variables DISTRO and DISTRO_VERSION in that order

DISTRO=${1}
DISTRO_VERSION=${2}

echo "[DEBUG] Building Dockerfile for ${DISTRO}:${DISTRO_VERSION}"

# If the container image isn't one we have a buildspec for then have a basic dockerfile using the root user

cat << EOF > dockerfile
FROM ${DISTRO}:${DISTRO_VERSION}

# Set the working directory
WORKDIR /root

EOF