#!/bin/bash
# This script creates symlinks from ~/ to a dotfiles directory cloned from github
# Github source is https://github.com/GingerGraham/linuxDotFiles

VERSION=2.0.1
OPT_STRING=":adf:hlo:"

TASK="" # Task to perform
DIR=$(pwd)
OLD_FILE_DIR=~/.oldDotFiles
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
    for FILE in $(find ${DIR} -type f -name ".*" -exec basename {} \;); do
        echo "${FILE}"
    done
    exit 0
}

copy_all_files () {
    echo "Copying all dot files"
    for FILE in $(find $dir -type f -name ".*" -exec basename {} \;); do
        if [ $FILE != ".gitignore" ]; then
            echo "Moving existing dotfiles from ~ to ${OLD_FILE_DIR}"
            if [ "${DRY_RUN}" = true ]; then
                echo "mv ~/${FILE} ${OLD_FILE_DIR}"
            else
                mv ~/"${FILE}" "${OLD_FILE_DIR}"
            fi
            echo "Creating symlink to ${FILE} in home directory."
            if [ "${DRY_RUN}" = true ]; then
                echo "ln -s ${DIR}/${FILE} ~/${FILE}"
            else
                ln -s "${DIR}"/"${FILE}" ~/"${FILE}"
            fi
        fi
    done
}

copy_selected_file () {
    echo "Copying ${COPY_FILE}"
    echo "Moving existing ${COPY_FILE} from ~ to ${OLD_FILE_DIR} if it exists"
    if [ "${DRY_RUN}" = true ]; then
        echo "mv ~/${COPY_FILE} ${OLD_FILE_DIR}"
    else
        mv ~/"${COPY_FILE}" "${OLD_FILE_DIR}"
    fi
    echo "Creating symlink to ${COPY_FILE} in home directory."
    if [ "${DRY_RUN}" = true ]; then
        echo "ln -s ${DIR}/${COPY_FILE} ~/${COPY_FILE}"
    else
        ln -s "${DIR}"/"${COPY_FILE}" ~/"${COPY_FILE}"
    fi
}

copy_theme_files () {
    echo "Copying theme files"
    # ln -s ${DIR}/gw-agnoster.zsh-theme ~/.oh-my-zsh/themes/gw-agnoster.zsh-theme
    for FILE in $(find ${DIR} -type f -name "*.zsh-theme" -exec basename {} \;); do
        echo "Moving existing dotfile from ~ to ${OLD_FILE_DIR}"
        if [ "${DRY_RUN}" = true ]; then
            echo "mv ~/${FILE} ${OLD_FILE_DIR}"
        else
            mv ~/"${FILE}" "${OLD_FILE_DIR}"
        fi
        echo "Creating symlink to ${FILE} in home directory."
        if [ "${DRY_RUN}" = true ]; then
            echo "ln -s ${DIR}/${FILE} ~/${FILE}"
        else
            ln -s "${DIR}"/"${FILE}" ~/"${FILE}"
        fi
    done
}

main "${@}"