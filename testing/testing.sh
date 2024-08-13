#!/bin/bash
# This script is used to provide a testing environment for the shell configuration contained within this repo
# The script will build a Docker image and run a container with mapping the linuxDotFiles directory to the container to allow for testing

VERSION=1.3.2
OPT_STRING=":d:huv:"

DISTRO=""
DISTRO_VERSION=""
# Set container name to be the name of the repo which would be the directory which is the parent of the directory this script is in
CONTAINER_NAME=$(basename "$(dirname "$(dirname "$(realpath "$0")")")" | tr '[:upper:]' '[:lower:]')

main () {
    opts "${@}"
    set_defaults
    echo "[INFO] Distribution: ${DISTRO}"
    echo "[INFO] Distribution version: ${DISTRO_VERSION}"
    script_dir
    test_docker
    set_image_tag
    build_image
    run_container
}

opts () {
    while getopts ${OPT_STRING} opt; do
        case $opt in
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
                echo "[ERROR] Invalid option: -${OPTARG}" >&2
                usage
                exit 1
                ;;
            :)
                echo "[ERROR] Option -${OPTARG} requires an argument." >&2
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
    echo "  -d <distro>         The Linux distribution to use for the Docker image"
    echo "  -h                  Display this help message"
    echo "  -u                  Update the Docker image"
    echo "  -v <distro_version> The version of the Linux distribution to use for the Docker image (default: latest)"
    echo

}

set_defaults () {
    # If values are not provided, set defaults
    if [[ -z ${DISTRO} ]]; then
        DISTRO="ubuntu"
    fi
    if [[ -z ${DISTRO_VERSION} ]]; then
        DISTRO_VERSION="latest"
    fi
    if [[ -z ${UPDATE_IMAGE} ]]; then
        UPDATE_IMAGE=false
    fi
    return 0
}

script_dir () {
    # Get the directory of the script and save it to a variable
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    echo "[INFO] Script directory: ${SCRIPT_DIR}"
    return 0
}

test_docker () {
    # Test if Docker is installed
    if ! [ -x "$(command -v docker)" ]; then
        echo "[ERROR] Docker is not installed" >&2
        exit 1
    fi
    echo "[INFO] Docker is installed"
    return 0
}

set_image_tag () {
    # Set the image tag based on the distribution and version
    # If the DISTRO contains a /, then replace it with a - to make it a valid tag
    # Do not change the DISTRO variable outside of this function
    local DISTRO="${DISTRO//\//-}"
    IMAGE_TAG="${DISTRO}-${DISTRO_VERSION}"
    echo "[INFO] Image tag: ${IMAGE_TAG}"
    return 0
}

image_exists () {
    # Check if the Docker image exists
    if [[ -z $(docker images -q ${CONTAINER_NAME}:"${IMAGE_TAG}") ]]; then
        IMAGE_EXISTS=false
    else
        IMAGE_EXISTS=true
    fi
    echo "[INFO] Image exists: ${IMAGE_EXISTS}"
    return 0
}

build_image () {
    # If the iamge already exists and the Version is not latest, then return
    image_exists
    if [[ ${IMAGE_EXISTS} == true ]] && [[ ${UPDATE_IMAGE} == false ]] && [[ ${DISTRO_VERSION} != "latest" ]]; then
        echo "[INFO] Image already exists"
        return 0
    fi

    # Switch based on the distribution to build the Docker image by calling the appropriate build script

    case ${DISTRO} in
        "ubuntu")
            echo "[INFO] Building Ubuntu Docker image"
            "${SCRIPT_DIR}"/build_ubuntu.sh "${DISTRO}" "${DISTRO_VERSION}"
            ;;
        "fedora")
            echo "[INFO] Building Fedora Docker image"
            "${SCRIPT_DIR}"/build_fedora.sh "${DISTRO}" "${DISTRO_VERSION}"
            ;;
        "opensuse"| "suse")
            # For these default to Tumbleweed by updating the DISTRO to opensuse/tumbleweed and log a WARN message
            DISTRO="opensuse/tumbleweed"
            echo "[WARN] openSUSE/SUSE not available, defaulting to openSUSE Tumbleweed"
            echo "[INFO] Building SUSE Docker image"
            "${SCRIPT_DIR}"/build_suse.sh "${DISTRO}" "${DISTRO_VERSION}"
            ;;
        "opensuse/leap")
            echo "[INFO] Building openSUSE Leap Docker image"
            "${SCRIPT_DIR}"/build_suse.sh "${DISTRO}" "${DISTRO_VERSION}"
            ;;
        "opensuse/tumbleweed")
            echo "[INFO] Building openSUSE Tumbleweed Docker image"
            "${SCRIPT_DIR}"/build_suse.sh "${DISTRO}" "${DISTRO_VERSION}"
            ;;
        *)
            echo "[INFO] Building generic Docker image"
            "${SCRIPT_DIR}"/build_generic.sh
            ;;
    esac

    docker build -t ${CONTAINER_NAME}:"${IMAGE_TAG}" --file dockerfile "${SCRIPT_DIR}"

    # Check if the build was successful
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Docker image build failed"
        exit 1
    fi
    echo "[INFO] Docker image built"
    # If a dockerfile exists, remove it
    if [[ -f "${SCRIPT_DIR}"/dockerfile ]]; then
        rm "${SCRIPT_DIR}"/dockerfile
    fi
    return 0
}

run_container () {
    # Run the Docker container and map the local directory to a directory in the container
    echo "[INFO] Running Docker container"
    # Check if the container already exists and if it does, remove it
    if [[ -n $(docker ps -a --filter "name=${CONTAINER_NAME}-${DISTRO}${DISTRO_VERSION}" --format '{{.Names}}') ]]; then
        echo "[WARN] Container exists, removing container"
        docker rm -f "${CONTAINER_NAME}-${DISTRO}${DISTRO_VERSION}"
        echo "[INFO] Container removed"
    fi
    echo "[INFO] Starting container"
    docker run -it -v "$(dirname "$(dirname "$(realpath "$0")")")":/home/test-user/testing:Z -u test-user --name "${CONTAINER_NAME}-${DISTRO}${DISTRO_VERSION}" --hostname "${CONTAINER_NAME}-${DISTRO}${DISTRO_VERSION}" ${CONTAINER_NAME}:"${IMAGE_TAG}"
    return 0
}

main "${@}"
