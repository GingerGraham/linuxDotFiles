#!/bin/bash
# This script is used to provide a testing environment for the shell configuration contained within this repo
# The script will build a Docker image and run a container with mapping the linuxDotFiles directory to the container to allow for testing

set -euo pipefail

# Sourcing standard logging library
REPO_ROOT="$(git rev-parse --show-toplevel)"
source "${REPO_ROOT}/utils/logging.sh"

# Initial logging
init_logger --journal --tag "DotFileTest" --color

VERSION=1.5.0
OPT_STRING=":cd:huv:"

DISTRO=""
DISTRO_VERSION=""
CLEANUP=false
# Set container name to be the name of the repo which would be the directory which is the parent of the directory this script is in
CONTAINER_NAME=$(basename "$(dirname "$(dirname "$(realpath "$0")")")" | tr '[:upper:]' '[:lower:]')

main () {
    opts "${@}"
    set_defaults
    log_info "Running $(basename "$0") version ${VERSION}"
    script_dir
    if [[ ${CLEANUP} == true ]]; then
        log_info "Cleaning up Docker images and containers"
        cleanup
        log_info "Cleanup complete"
        exit 0
    fi
    log_info "Distribution: ${DISTRO}"
    log_info "Distribution version: ${DISTRO_VERSION}"
    test_docker
    set_image_tag
    build_image
    run_container
}

opts () {
    while getopts ${OPT_STRING} opt; do
        case $opt in
            c)
                CLEANUP=true
                ;;
            d)
                DISTRO="${OPTARG}"
                ;;
            h)
                usage
                exit 0
                ;;
            u)
                UPDATE_IMAGE=true
                ;;
            v)
                DISTRO_VERSION="${OPTARG}"
                ;;
            \?)
                log_error "Invalid option: -${OPTARG}" >&2
                usage
                exit 1
                ;;
            :)
                log_error "Option -${OPTARG} requires an argument." >&2
                usage
                exit 1
                ;;
        esac
    done
}

usage () {
    # Display script help/usage
    echo "Version ${VERSION}"
    echo
    echo "Purpose: This script is used to provide a testing environment for the shell configuration contained within this repo"
    echo
    echo "Usage: $(basename $0) [-d <distro>] [-h] [-v <distro_version>]"
    echo
    echo "Options:"
    echo "  -c                  Cleanup the Docker images and containers"
    echo "  -d <distro>         The Linux distribution to use for the Docker image (default: ubuntu)"
    echo "  -u                  Update the Docker image"
    echo "  -v <distro_version> The version of the Linux distribution to use for the Docker image (default: latest)"
    echo "  -h                  Display this help message"
    echo
    echo "Examples:"
    echo "  $(basename $0)  #Default to Ubuntu latest"
    echo "  $(basename $0) -d ubuntu -v 20.04"
    echo "  $(basename $0) -d fedora -v 32"
    echo "  $(basename $0) -d opensuse -v tumbleweed"
    echo "  $(basename $0) -c"
    echo
    echo "Warning: The -c option will remove all Docker images and containers with the name ${CONTAINER_NAME}. When the image is removed if other projects have also used the same image, they will also be removed"
    return 0
}

set_defaults () {
    # If values are not provided, set defaults
    if [[ -z ${DISTRO:-} ]]; then
        DISTRO="ubuntu"
    fi
    if [[ -z ${DISTRO_VERSION:-} ]]; then
        DISTRO_VERSION="latest"
    fi
    if [[ -z ${UPDATE_IMAGE:-} ]]; then
        UPDATE_IMAGE=false
    fi
    return 0
}

cleanup () {
    # Remove the Docker image and container created by the testing script and remove the dockerfile
    log_info "Cleaning up Docker images and containers"
    # Remove all dotfiletest containers
    if docker ps -a | grep "${CONTAINER_NAME}" | awk '{print $1}' | xargs -I {} docker rm -f {}; then
        log_info "Containers removed"
    else
        log_error "Failed to remove containers"
    fi
    # Remove all dotfiletest images
    if docker images | grep "${CONTAINER_NAME}" | awk '{print $3}' | xargs -I {} docker rmi -f {}; then
        log_info "Images removed"
    else
        log_error "Failed to remove images"
    fi
    # Remove the dockerfile from the directory that this script is held in regardless of the current working directory
    if [[ -f "${SCRIPT_DIR}"/dockerfile ]]; then
        if rm "${SCRIPT_DIR}"/dockerfile; then
            log_info "Dockerfile removed"
        else
            log_error "Failed to remove dockerfile"
        fi
    fi
    # If the dockerfile was created in the dir above the current working directory, remove it
    if [[ -f "$(dirname "$(dirname "${SCRIPT_DIR}")")"/dockerfile ]]; then
        if rm "$(dirname "$(dirname "${SCRIPT_DIR}")")"/dockerfile; then
            log_info "Dockerfile removed"
        else
            log_error "Failed to remove dockerfile"
        fi
    fi
    return 0
}

script_dir () {
    # Get the directory of the script and save it to a variable
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    log_info "Script directory: ${SCRIPT_DIR}"
    return 0
}

test_docker () {
    # Test if Docker is installed
    if ! [ -x "$(command -v docker)" ]; then
        log_error "Docker is not installed" >&2
        log_error "Please install Docker before running this script" >&2
        log_error "If using podman please install podman-docker" >&2
        exit 1
    fi
    log_info "Docker is installed"
    return 0
}

set_image_tag () {
    # Set the image tag based on the distribution and version
    # If the DISTRO contains a /, then replace it with a - to make it a valid tag
    # Do not change the DISTRO variable outside of this function
    local DISTRO="${DISTRO//\//-}"
    IMAGE_TAG="${DISTRO}-${DISTRO_VERSION}"
    log_info "Image tag: ${IMAGE_TAG}"
    return 0
}

image_exists () {
    # Check if the Docker image exists
    if [[ -z $(docker images -q ${CONTAINER_NAME}:"${IMAGE_TAG}") ]]; then
        IMAGE_EXISTS=false
    else
        IMAGE_EXISTS=true
    fi
    log_info "Image exists: ${IMAGE_EXISTS}"
    return 0
}

build_image () {
    # If the iamge already exists and the Version is not latest, then return
    image_exists
    if [[ ${IMAGE_EXISTS} == true ]] && [[ ${UPDATE_IMAGE} == false ]] && [[ ${DISTRO_VERSION} != "latest" ]]; then
        log_info "Image already exists"
        return 0
    fi

    # Switch based on the distribution to build the Docker image by calling the appropriate build script

    case ${DISTRO} in
        "ubuntu")
            log_info "Building Ubuntu Docker image"
            "${SCRIPT_DIR}"/build_ubuntu.sh "${DISTRO}" "${DISTRO_VERSION}"
            ;;
        "fedora")
            log_info "Building Fedora Docker image"
            "${SCRIPT_DIR}"/build_fedora.sh "${DISTRO}" "${DISTRO_VERSION}"
            ;;
        "opensuse"| "suse")
            # For these default to Tumbleweed by updating the DISTRO to opensuse/tumbleweed and log a WARN message
            DISTRO="opensuse/tumbleweed"
            log_warn "openSUSE/SUSE not available, defaulting to openSUSE Tumbleweed"
            log_info "Building SUSE Docker image"
            "${SCRIPT_DIR}"/build_suse.sh "${DISTRO}" "${DISTRO_VERSION}"
            ;;
        "opensuse/leap")
            log_info "Building openSUSE Leap Docker image"
            "${SCRIPT_DIR}"/build_suse.sh "${DISTRO}" "${DISTRO_VERSION}"
            ;;
        "opensuse/tumbleweed")
            log_info "Building openSUSE Tumbleweed Docker image"
            "${SCRIPT_DIR}"/build_suse.sh "${DISTRO}" "${DISTRO_VERSION}"
            ;;
        *)
            log_info "Building generic Docker image"
            "${SCRIPT_DIR}"/build_generic.sh
            ;;
    esac

    docker build -t ${CONTAINER_NAME}:"${IMAGE_TAG}" --file dockerfile "${SCRIPT_DIR}"

    # Check if the build was successful
    if [[ $? -ne 0 ]]; then
        log_error "Docker image build failed"
        exit 1
    fi
    log_info "Docker image built"
    # If a dockerfile exists, remove it
    if [[ -f "${SCRIPT_DIR}"/dockerfile ]]; then
        rm "${SCRIPT_DIR}"/dockerfile
    fi
    return 0
}

run_container () {
    # Run the Docker container and map the local directory to a directory in the container
    log_info "Running Docker container"
    # Check if the container already exists and if it does, remove it
    if [[ -n $(docker ps -a --filter "name=${CONTAINER_NAME}-${DISTRO}${DISTRO_VERSION}" --format '{{.Names}}') ]]; then
        log_warn "Container exists, removing container"
        docker rm -f "${CONTAINER_NAME}-${DISTRO}${DISTRO_VERSION}"
        log_info "Container removed"
    fi
    log_info "Starting container"
    docker run -it -v "$(dirname "$(dirname "$(realpath "$0")")")":/home/test-user/testing:Z -u test-user --name "${CONTAINER_NAME}-${DISTRO}${DISTRO_VERSION}" --hostname "${CONTAINER_NAME}-${DISTRO}${DISTRO_VERSION}" ${CONTAINER_NAME}:"${IMAGE_TAG}"
    return 0
}

main "${@}"
