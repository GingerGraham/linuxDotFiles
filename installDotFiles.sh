#!/bin/bash
# This script creates symlinks from ${HOME}/ to a dotfiles directory cloned from github
# Github source is https://github.com/GingerGraham/linuxDotFiles

VERSION=2.1.1
OPT_STRING=":adf:hlo:"

TASK="" # Task to perform
DIR=$(pwd)
OLD_FILE_DIR=${HOME}/.oldDotFiles
COPY_FILE="" # File to copy
DRY_RUN=false

main () {
    opts "${@}"
    if [[ -z ${TASK} ]]; then
        echo "No task selected" >&2
        usage
        exit 1
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
                echo "Dry run" >&2
                DRY_RUN=true
                ;;
            f)
                set_copy_file "${OPTARG}"
                TASK=("copy_selected_file")
                ;;
            h)
                usage
                exit 0
                ;;
            l)
                list_files
                ;;
            o)
                set_old_file_dir "${OPTARG}"
                ;;
            \?)
                echo "Invalid option: -${OPTARG}" >&2
                usage
                exit 1
                ;;
            :)
                echo "Option -${OPTARG} requires an argument." >&2
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
    echo "Purpose: This script creates symlinks from ${HOME}/ to a dotfiles directory cloned from github"
    echo
    echo "Usage: $(basename $0) [-a] [-d] [-f <file>] [-h] [-l] [-o <dir>]"
    echo
    echo "  -a  Copy all dot files"
    echo "  -d  Dry run"
    echo "  -f  Copy file <file>"
    echo "  -h  Display this help message"
    echo "  -l  List available files"
    echo "  -o  Use <dir> for existing dot files"
    exit 0
}

set_old_file_dir () {
    if [ -d "${1}" ]; then
        OLD_FILE_DIR="${1}"
    else
        echo "Directory ${1} does not exist, using ${OLD_FILE_DIR} for existing dot files"
    fi
}

set_copy_file () {
    if [ -f "${1}" ]; then
        COPY_FILE="${1}"
    else
        echo "File ${1} does not exist, exiting"
        exit 1
    fi
}

list_files () {
    echo "Listing available files in ${DIR}"
    find ${DIR} -type d -not -path "*/.git/*" -not -name ".git" -not -name "docs" | while IFS= read -r SUBDIR; do
        echo "Subdirectory: ${SUBDIR}"
        find ${SUBDIR} -type f -name ".*" -exec basename {} \; | while IFS= read -r FILE; do
            echo "${FILE}"
        done
    done
    exit 0
}

create_old_file_dir () {
	CURRENT_DATE=$(date +"%Y-%m-%d")
	CURRENT_TIME=$(date +"%H-%M-%S")
	SUBDIR="${OLD_FILE_DIR}/${CURRENT_DATE}/${CURRENT_TIME}"
	
	if [ ! -d "${SUBDIR}" ]; then
		echo "Creating ${SUBDIR} for existing dot files"
		if [ "${DRY_RUN}" = true ]; then
			echo "mkdir -p ${SUBDIR}"
		else
			mkdir -p "${SUBDIR}"
		fi
	fi
	
	OLD_FILE_DIR="${SUBDIR}"
}

copy_all_files () {
    echo "Ensuring ${OLD_FILE_DIR} exists and creating if it does not"
    create_old_file_dir
    echo "Copying all dot files"
    
    # Find the dot files in any subdirectory
    find ${DIR} -type d -not -path "*/.git/*" -not -name ".git" -not -name "docs" | while IFS= read -r SUBDIR; do
        echo "Subdirectory: ${SUBDIR}"
        find "${SUBDIR}" -type f -name ".*" -exec basename {} \; | while IFS= read -r FILE; do
            if [ "${FILE}" != ".gitignore" ]; then
                echo "Moving existing ${FILE} from ${HOME} to ${OLD_FILE_DIR} if it exists"
                if [ "${DRY_RUN}" = true ]; then
                    echo "mv ${HOME}/${FILE} ${OLD_FILE_DIR}"
                else
                    if [ ! -L "${HOME}/${FILE}" ]; then
                        mv ${HOME}/"${FILE}" "${OLD_FILE_DIR}"
                    else
                        echo "Skipping symlink: ${HOME}/${FILE}"
                    fi
                fi
                echo "Creating symlink from ${SUBDIR}/${FILE} to $(readlink -f ${HOME}/${FILE})"
                if [ "${DRY_RUN}" = true ]; then
                    echo "ln -s ${SUBDIR}/${FILE} ${HOME}/${FILE}"
                else
                    ln -s "${SUBDIR}"/"${FILE}" ${HOME}/"${FILE}"
                fi
            fi
        done
    done
    # If there are one or more subdirectories of ./Shell (relative to the current directory of this script) then create directory links to them in ${HOME}
    if [ -d "${DIR}/Shell" ]; then
        echo "Creating directory links to ${DIR}/Shell subdirectories in ${HOME}"
        find "${DIR}/Shell" -type d -not -path "*/.git/*" -not -name ".git" -not -name "docs" | while IFS= read -r SUBDIR; do
            echo "Creating symlink from ${SUBDIR} to ${HOME}/$(basename ${SUBDIR})"
            if [ "${DRY_RUN}" = true ]; then
                echo "ln -s ${SUBDIR} ${HOME}/$(basename ${SUBDIR})"
            else
                ln -s "${SUBDIR}" ${HOME}/$(basename ${SUBDIR})
            fi
        done
    fi
}

copy_selected_file () {
    echo "Ensuring ${OLD_FILE_DIR} exists and creating if it does not"
    create_old_file_dir
    echo "Copying ${COPY_FILE}"

    # Find the file(s) in any subdirectory
    find ${DIR} -type d -not -path "*/.git/*" -not -name ".git" -not -name "docs" | while IFS= read -r SUBDIR; do
        echo "Subdirectory: ${SUBDIR}"
        find "${SUBDIR}" -type f -name "${COPY_FILE}" -exec basename {} \; | while IFS= read -r FILE; do
            echo "Moving existing ${FILE} from ${HOME} to ${OLD_FILE_DIR} if it exists"
            if [ "${DRY_RUN}" = true ]; then
                echo "mv ${HOME}/${FILE} ${OLD_FILE_DIR}"
            else
                if [ ! -L "${HOME}/${FILE}" ]; then
                    mv ${HOME}/"${FILE}" "${OLD_FILE_DIR}"
                else
                    echo "Skipping symlink: ${HOME}/${FILE}"
                fi
            fi
            echo "Creating symlink from ${SUBDIR}/${FILE} to $(readlink -f ${HOME}/${FILE})"
            if [ "${DRY_RUN}" = true ]; then
                echo "ln -s ${SUBDIR}/${FILE} ${HOME}/${FILE}"
            else
                ln -s "${SUBDIR}"/"${FILE}" ${HOME}/"${FILE}"
            fi
        done
    done
    # If the file being copied is .applets then also look for a ./Shell/applets directory in the repo relative to this script and create a symlink to it in ${HOME}
    if [ "${COPY_FILE}" = ".applets" ]; then
        if [ -d "${DIR}/Shell/applets" ]; then
            echo "Creating symlink from ${DIR}/Shell/applets to ${HOME}/applets"
            if [ "${DRY_RUN}" = true ]; then
                echo "ln -s ${DIR}/Shell/applets ${HOME}/applets"
            else
                ln -s "${DIR}/Shell/applets" ${HOME}/applets
            fi
        fi
    fi
}

copy_theme_files () {
    echo "Copying theme files"
    # ln -s ${DIR}/gw-agnoster.zsh-theme ${HOME}/.oh-my-zsh/themes/gw-agnoster.zsh-theme
    for FILE in $(find ${DIR} -type f -name "*.zsh-theme" -exec basename {} \;); do
        echo "Moving existing dotfile from ${HOME} to ${OLD_FILE_DIR}"
        if [ "${DRY_RUN}" = true ]; then
            echo "mv ${HOME}/${FILE} ${OLD_FILE_DIR}"
        else
            mv ${HOME}/"${FILE}" "${OLD_FILE_DIR}"
        fi
        echo "Creating symlink to ${FILE} in home directory."
        if [ "${DRY_RUN}" = true ]; then
            echo "ln -s ${DIR}/${FILE} ${HOME}/${FILE}"
        else
            ln -s "${DIR}"/"${FILE}" ${HOME}/"${FILE}"
        fi
    done
}

main "${@}"