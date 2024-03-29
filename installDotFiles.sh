#!/bin/bash
# This script creates symlinks from ${HOME}/ to a dotfiles directory cloned from github
# Github source is https://github.com/GingerGraham/linuxDotFiles

VERSION=2.2.1
OPT_STRING=":adf:hlo:"

TASK="" # Task to perform
# DIR=$(pwd)
DIR=$(dirname "${0}")
OLD_FILE_DIR=${HOME}/.oldDotFiles
COPY_FILE="" # File to copy
DRY_RUN=false
EXCLUDE_DIRS=("docs" "docker" "testing" ".git")
EXCLUDE_FILES=(".gitignore" "installDotFiles.sh" "README.md")

# Generate an EXCLUDED_DIRS_ARGS string to pass to the find command
EXCLUDED_DIRS_ARGS=""
for dir in "${EXCLUDE_DIRS[@]}"; do
    # If dir is .git then exclude it and any subdirectories
    EXCLUDED_DIRS_ARGS+=" -not -name ${dir}"
done

# Generate an EXCLUDED_FILES_ARGS string to pass to the find
EXCLUDED_FILES_ARGS=""
for file in "${EXCLUDE_FILES[@]}"; do
    EXCLUDED_FILES_ARGS+=" -not -name ${file}"
done

main () {
    opts "${@}"
    if [[ -z ${TASK} ]]; then
        echo "[ERROR] No task selected" >&2
        usage
        return 1
    fi
    for task in "${TASK[@]}"; do
        ${task}
    done
}

opts () {
    while getopts ${OPT_STRING} opt; do
        case $opt in
            a)
                TASK=("copy_all_files")
                ;;
            d)
                echo "[WARN] Dry run selected - no files or links will be changed" >&2
                DRY_RUN=true
                ;;
            f)
                set_copy_file "${OPTARG}"
                TASK=("copy_selected_file")
                ;;
            h)
                usage
                return 0
                ;;
            l)
                list_files
                ;;
            o)
                set_old_file_dir "${OPTARG}"
                ;;
            \?)
                echo "[ERROR] Invalid option: -${OPTARG}" >&2
                usage
                return 1
                ;;
            :)
                echo "[ERROR] Option -${OPTARG} requires an argument." >&2
                usage
                return 1
                ;;
        esac
    done
}

usage () {
    # Display script help/usage
    echo "Version ${VERSION}"
    echo
    echo "Purpose: This script creates symlinks from ${HOME}/ to a dotfiles directory cloned from github"
    echo
    echo "Usage: $(basename "$0") [-a] [-d] [-f <file>] [-h] [-l] [-o <dir>]"
    echo
    echo "  -a  Copy all dot files"
    echo "  -d  Dry run"
    echo "  -f  Copy file <file>"
    echo "  -h  Display this help message"
    echo "  -l  List available files"
    echo "  -o  Use <dir> for existing dot files"
    return 0
}

set_old_file_dir () {
    if [ -d "${1}" ]; then
        OLD_FILE_DIR="${1}"
    else
        echo "[WARN] Directory ${1} does not exist, using ${OLD_FILE_DIR} for existing dot files"
    fi
    return 0
}

set_copy_file () {
    # Ensure an argument is passed in and set the COPY_FILE variable or return an error
    if [ -z "${1}" ]; then
        echo "[ERROR] No file name passed in, returning"
        echo "[INFO] Use -l to list available files"
        return 1
    fi
    COPY_FILE="${1}"
}

list_files () {
    echo "[INFO] Listing available files in ${DIR}"
    find "${DIR}" -type f -name ".*" ${EXCLUDED_FILES_ARGS} -exec basename {} \;
    return 0
}

source_shrc () {
    # Get the current user
    if [ -n "$USER" ]; then
        local user="$USER"
    elif [ -n "$USERNAME" ]; then
        local user="$USERNAME"
    elif [ -n "$(whoami)" ]; then
        local user
        user="$(whoami)"
    else
        echo "[ERROR] Unable to determine the user"
        return 1
    fi
    echo "[DEBUG] User is ${user}"
    # If the user is not found, return an error
    if [ -z "$user" ]; then
        echo "[ERROR] Unable to determine the user"
        return 1
    fi
    # Get the user's default shell
    local shell
    shell=$(getent passwd "$user" | cut -d: -f7 | sed 's/\/bin\///' | sed 's/\/usr\///' | sed 's/usr//')
    shell=${shell##*/}
    # echo "[DEBUG] Shell is ${shell}"
    # echo "[INFO] Sourcing ${HOME}/.${shell}rc"
    # # shellcheck source=/dev/null
    # if [ "${DRY_RUN}" = true ]; then
    #     echo "source ${HOME}/.${shell}rc"
    # else
    #     echo "[DEBUG] Sourcing ${HOME}/.${shell}rc"
    #     source "${HOME}/.${shell}rc"
    #     echo "[DEBUG] Sourced ${HOME}/.${shell}rc"
    # fi
    # # If the last command failed, return an error
    # if [ $? -ne 0 ]; then
    #     echo "[ERROR] Unable to source ${HOME}/.${shell}rc"
    #     return 1
    # fi
    # echo "[INFO] Sourced ${HOME}/.${shell}rc if aliases or applets were added, they are now available in the current shell. If not run the command below manually."
    echo "[INFO] Run the command below manually to source the ${HOME}/.${shell}rc file"
    echo "source ${HOME}/.${shell}rc"
    return 0
}

create_old_file_dir () {
	CURRENT_DATE=$(date +"%Y-%m-%d")
	CURRENT_TIME=$(date +"%H-%M-%S")
	SUBDIR="${OLD_FILE_DIR}/${CURRENT_DATE}/${CURRENT_TIME}"

	if [ ! -d "${SUBDIR}" ]; then
		echo "[INFO] Creating ${SUBDIR} for existing dot files"
		if [ "${DRY_RUN}" = true ]; then
			echo "mkdir -p ${SUBDIR}"
		else
			mkdir -p "${SUBDIR}"
		fi
	fi
	OLD_FILE_DIR="${SUBDIR}"
    return 0
}

copy_all_files () {
    echo "[INFO] Ensuring ${OLD_FILE_DIR} exists and creating if it does not"
    create_old_file_dir
    echo "[INFO] Copying all dot files"

    # Find the dot files in any subdirectory
    find "${DIR}" -type f -name ".*" ${EXCLUDED_FILES_ARGS} -not -path "*/.git/*" | while IFS= read -r FILE; do
        FILENAME=$(basename "${FILE}")
        echo "[INFO] Moving existing ${FILENAME} from ${HOME} to ${OLD_FILE_DIR} if it exists"
        if [ "${DRY_RUN}" = true ]; then
            echo "mv ${HOME}/${FILENAME} ${OLD_FILE_DIR}"
        else
            if [ ! -L "${HOME}/${FILENAME}" ]; then
                mv "${HOME}/${FILENAME}" "${OLD_FILE_DIR}"
            else
                echo "[INFO] Skipping symlink: ${HOME}/${FILENAME}"
            fi
        fi
        echo "[INFO] Creating symlink from ${FILE} to ${HOME}/${FILENAME}"
        if [ "${DRY_RUN}" = true ]; then
            echo "ln -sf ${FILE} ${HOME}/${FILENAME}"
        else
            ln -sf "$(realpath --relative-to="${HOME}" "${FILE}")" "${HOME}/${FILENAME}"
        fi
    done
    echo "[DEBUG] Copying machine specific config file"
    # Copy machine_local.template to ${HOME}/.machine_local if it does not exist
    if [ ! -f "${HOME}/.machine_local" ]; then
        echo "[INFO] Copying ${DIR}/Shell/machine_local.template to ${HOME}/.machine_local"
        if [ "${DRY_RUN}" = true ]; then
            echo "cp ${DIR}/Shell/machine_local.template ${HOME}/.machine_local"
        else
            cp "${DIR}/Shell/machine_local.template" "${HOME}/.machine_local"
        fi
    fi
    # echo "[DEBUG] Linking directories"
    # If there are one or more subdirectories of ./Shell (relative to the current directory of this script) then create directory links to them in ${HOME}
    if [ -d "${DIR}/Shell" ]; then
        echo "[INFO] Creating directory links to ${DIR}/Shell subdirectories in ${HOME}"
        find "${DIR}/Shell" -mindepth 1 -maxdepth 1 -type d ${EXCLUDED_DIRS_ARGS} | while IFS= read -r SUBDIR; do
            echo "[INFO] Creating symlink from ${SUBDIR} to ${HOME}/$(basename "${SUBDIR}")"
            if [ "${DRY_RUN}" = true ]; then
                echo "ln -sf $(realpath --relative-to="${HOME}" "${SUBDIR}") ${HOME}/$(basename "${SUBDIR}")"
            else
                ln -sf "$(realpath --relative-to="${HOME}" "${SUBDIR}")" "${HOME}"/"$(basename "${SUBDIR}")"
            fi
        done
    fi
    # Source the shell rc file
    source_shrc
    return 0
}

copy_selected_file () {
    # Handle the file name passed in and if not file name is passed return an error
    if [ -z "${COPY_FILE}" ]; then
        echo "[ERROR] No file name passed in, returning"
        echo "[INFO] Use -l to list available files"
        return 1
    fi
    echo "[INFO] Ensuring ${OLD_FILE_DIR} exists and creating if it does not"
    create_old_file_dir
    echo "[INFO] Copying ${COPY_FILE}"
    # Search the parent directory of this script and all subdirectories for the file name passed in
    FILE=$(find "${DIR}" -type f -name "${COPY_FILE}" ${EXCLUDED_FILES_ARGS} "${EXCLUDED_DIRS_ARGS}")
    if [ -z "${FILE}" ]; then
        echo "[ERROR] File ${COPY_FILE} not found"
        return 1
    fi
    # If the file is found then move the existing file to the OLD_FILE_DIR and create a symlink to the new file
    FILENAME=$(basename "${FILE}")
    echo "[INFO] Moving existing ${FILENAME} from ${HOME} to ${OLD_FILE_DIR} if it exists"
    if [ "${DRY_RUN}" = true ]; then
        echo "mv ${HOME}/${FILENAME} ${OLD_FILE_DIR}"
    else
        if [ ! -L "${HOME}/${FILENAME}" ]; then
            mv "${HOME}/${FILENAME}" "${OLD_FILE_DIR}"
        else
            echo "[INFO] Skipping symlink: ${HOME}/${FILENAME}"
        fi
    fi
    echo "[INFO] Creating symlink from ${FILE} to ${HOME}/${FILENAME}"
    if [ "${DRY_RUN}" = true ]; then
        echo "ln -sf ${FILE} ${HOME}/${FILENAME}"
    else
        ln -sf "$(realpath --relative-to="${HOME}" "${FILE}")" "${HOME}/${FILENAME}"
    fi
    # If COPY_FILE is .applets then we also need to symlink ${DIR}/Shell/applets to ${HOME}/.applets
    if [ "${COPY_FILE}" = ".applets" ]; then
        echo "[INFO] Creating symlink from ${DIR}/Shell/applets to ${HOME}/applets"
        if [ "${DRY_RUN}" = true ]; then
            echo "ln -sf ${DIR}/Shell/applets ${HOME}/applets"
        else
            ln -sf "$(realpath --relative-to="${HOME}" "${DIR}/Shell/applets")" "${HOME}/applets"
        fi
    fi
    # If the file copied is a shell rc file then source it by calling source_shrc
    if [[ "${COPY_FILE}" =~ ^\..*rc$ ]]; then
        source_shrc
    fi
    return 0
}

main "${@}"