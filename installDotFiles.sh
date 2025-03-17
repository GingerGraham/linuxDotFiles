#!/usr/bin/env bash
# This script creates symlinks from ${HOME}/ to a dotfiles directory cloned from github
# Github source is https://github.com/GingerGraham/linuxDotFiles

VERSION=3.0.3

# Sourcing standard logging library
REPO_ROOT="$(git rev-parse --show-toplevel)"
source "${REPO_ROOT}/utils/logging.sh"

init_logger --color --journal --tag "$(basename "${0}")"

# Global variables
TASK="" # Task to perform
DIR=$(dirname "${0}")
OLD_FILE_DIR=${HOME}/.oldDotFiles
COPY_FILE="" # File to copy
DRY_RUN=false
EXCLUDE_DIRS=("docs" "docker" "testing" ".git")
EXCLUDE_FILES=(".gitignore" "installDotFiles.sh" "README.md")

# Generate an EXCLUDED_DIRS_ARGS string to pass to the find command
EXCLUDED_DIRS_ARGS=""
for dir in "${EXCLUDE_DIRS[@]}"; do
    EXCLUDED_DIRS_ARGS+=" -not -name ${dir}"
done

# Generate an EXCLUDED_FILES_ARGS string to pass to the find
EXCLUDED_FILES_ARGS=""
for file in "${EXCLUDE_FILES[@]}"; do
    EXCLUDED_FILES_ARGS+=" -not -name ${file}"
done

main () {
    parse_args "${@}"
    if [[ -z ${TASK} ]]; then
        log_error "No task selected" >&2
        usage
        return 1
    fi
    
    # Always ensure utils directory is linked first
    link_utils_directory

    for task in "${TASK[@]}"; do
        ${task}
    done
}

parse_args() {
    # Manual argument parsing
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                TASK=("copy_all_files")
                shift
                ;;
            -C|--check|--dry-run)
                log_warn "Dry run selected - no files or links will be changed" >&2
                DRY_RUN=true
                shift
                ;;
            -f|--file)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Option $1 requires an argument." >&2
                    usage
                    exit 1
                fi
                set_copy_file "$2"
                TASK=("copy_selected_file")
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -l|--list)
                list_files
                exit 0
                ;;
            -o|--old-dir)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Option $1 requires an argument." >&2
                    usage
                    exit 1
                fi
                set_old_file_dir "$2"
                shift 2
                ;;
            -v|--version)
                echo "$(basename "${0}") version ${VERSION}"
                exit 0
                ;;
            -d|--debug|--verbose)
                set_log_level "DEBUG"
                shift
                ;;
            *)
                log_error "Unknown option: $1" >&2
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
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo
    echo "Options:"
    echo "  -a, --all                   Copy all dot files"
    echo "  -f, --file <file>           Copy specific file <file>"
    echo "  -l, --list                  List available files"
    echo "  -o, --old-dir <dir>         Use <dir> for existing dot files"
    echo "  -C, --check, --dry-run      Dry run - show what would happen but won't make changes"
    echo "  -v, --version               Display version information"
    echo "  -d, --debug, --verbose      Enable debug logging"
    echo "  -h, --help                  Display this help message"
    return 0
}

set_old_file_dir () {
    if [ -d "${1}" ]; then
        OLD_FILE_DIR="${1}"
    else
        log_warn "Directory ${1} does not exist, using ${OLD_FILE_DIR} for existing dot files"
    fi
    return 0
}

set_copy_file () {
    # Ensure an argument is passed in and set the COPY_FILE variable or return an error
    if [ -z "${1}" ]; then
        log_error "No file name passed in, returning"
        log_info "Use -l to list available files"
        return 1
    fi
    COPY_FILE="${1}"
}

list_files () {
    log_info "Listing available files in ${DIR}"
    find "${DIR}" -type f -name ".*" ${EXCLUDED_FILES_ARGS} -exec basename {} \;
    return 0
}

source_shell_rc() {
    # Get the current user
    if [ -n "$USER" ]; then
        local user="$USER"
    elif [ -n "$USERNAME" ]; then
        local user="$USERNAME"
    elif [ -n "$(whoami)" ]; then
        local user
        user="$(whoami)"
    else
        log_error "Unable to determine the user"
        return 1
    fi
    log_debug "User is ${user}"
    
    # If the user is not found, return an error
    if [ -z "$user" ]; then
        log_error "Unable to determine the user"
        return 1
    fi
    
    # Get the user's default shell
    local shell
    shell=$(basename "$SHELL")
    shell=${shell##*/}
    
    # Try to source the shell rc file
    local rc_file="${HOME}/.${shell}rc"
    
    if [ -f "$rc_file" ]; then
        log_info "Attempting to source ${rc_file}"
        if [ "${DRY_RUN}" = true ]; then
            echo "source ${rc_file}"
        else
            # Try to source the RC file
            if [ "$shell" = "bash" ]; then
                # For bash, we can use the source command
                if source "$rc_file" 2>/dev/null; then
                    log_info "Successfully sourced ${rc_file}"
                    return 0
                fi
            elif [ "$shell" = "zsh" ]; then
                # For zsh, we need to use the dot command
                if source "$rc_file" 2>/dev/null; then
                    log_info "Successfully sourced ${rc_file}"
                    return 0
                fi
            else
                # Try both methods for other shells
                if source "$rc_file" 2>/dev/null || . "$rc_file" 2>/dev/null; then
                    log_info "Successfully sourced ${rc_file}"
                    return 0
                fi
            fi
            
            # If we get here, sourcing failed
            log_warn "Could not automatically source ${rc_file}"
        fi
    else
        log_warn "Shell RC file ${rc_file} not found"
    fi
    
    # Fall back to showing the command
    log_info "Run the command below manually to source the ${rc_file} file:"
    echo "source ${rc_file}"
    return 0
}

create_old_file_dir () {
    CURRENT_DATE=$(date +"%Y-%m-%d")
    CURRENT_TIME=$(date +"%H-%M-%S")
    SUBDIR="${OLD_FILE_DIR}/${CURRENT_DATE}/${CURRENT_TIME}"

    if [ ! -d "${SUBDIR}" ]; then
        log_info "Creating ${SUBDIR} for existing dot files"
        if [ "${DRY_RUN}" = true ]; then
            echo "mkdir -p ${SUBDIR}"
        else
            mkdir -p "${SUBDIR}"
        fi
    fi
    OLD_FILE_DIR="${SUBDIR}"
    return 0
}

# Refactored function to create a symlink
create_symlink() {
    local source_path="$1"
    local target_path="$2"
    
    log_info "Creating symlink from ${source_path} to ${target_path}"
    if [ "${DRY_RUN}" = true ]; then
        echo "ln -sf $(realpath --relative-to="$(dirname "${target_path}")" "${source_path}") ${target_path}"
    else
        ln -sf "$(realpath --relative-to="$(dirname "${target_path}")" "${source_path}")" "${target_path}"
    fi
}

# Refactored function to handle moving existing files
move_existing_file() {
    local source_path="$1"
    local dest_dir="$2"
    
    if [ -e "${source_path}" ]; then
        if [ -L "${source_path}" ]; then
            log_debug "Removing existing symlink: ${source_path}"
            if [ "${DRY_RUN}" = true ]; then
                echo "rm ${source_path}"
            else
                rm "${source_path}"
            fi
            return 0
        else
            log_info "Moving existing $(basename "${source_path}") from $(dirname "${source_path}") to ${dest_dir}"
            if [ "${DRY_RUN}" = true ]; then
                echo "mv ${source_path} ${dest_dir}"
            else
                mv "${source_path}" "${dest_dir}" 2>/dev/null || true
            fi
        fi
    else
        log_debug "No existing file at ${source_path}"
    fi
}

# Special handling for the .applets file and directory
handle_applets_special_case() {
    local shelldir="${DIR}/Shell"
    
    # Check if we're already in the applets directory to avoid recursive symlink
    if [ "$(pwd)" = "${shelldir}/applets" ]; then
        echo "[WARN] Already in ${shelldir}/applets directory, skipping symlink to avoid recursion"
        return
    fi
    
    # Create symlink from Shell/applets directory to HOME/applets
    if [ -d "${shelldir}/applets" ]; then
        # Ensure we're not creating a symlink to itself
        if [ -e "${HOME}/applets" ] && [ "$(readlink -f "${HOME}/applets")" = "$(readlink -f "${shelldir}/applets")" ]; then
            log_info "Symlink for applets already points to the correct location"
        else
            # Remove any existing incorrect symlink
            if [ -L "${HOME}/applets" ]; then
                log_info "Removing existing incorrect symlink: ${HOME}/applets"
                if [ "${DRY_RUN}" = true ]; then
                    echo "rm ${HOME}/applets"
                else
                    rm "${HOME}/applets"
                fi
            fi
            # Create the symlink with absolute paths to avoid confusion
            log_info "Creating symlink from ${shelldir}/applets to ${HOME}/applets"
            if [ "${DRY_RUN}" = true ]; then
                echo "ln -sf $(readlink -f "${shelldir}/applets") ${HOME}/applets"
            else
                ln -sf "$(readlink -f "${shelldir}/applets")" "${HOME}/applets"
            fi
        fi
    else
        echo "[WARN] ${shelldir}/applets directory not found, skipping applets directory symlink"
    fi
}

link_utils_directory() {
    log_debug "Ensuring utils directory is linked to ${HOME}/utils"
    
    if [ -d "${DIR}/utils" ]; then
        if [ -d "${HOME}/utils" ] && [ ! -L "${HOME}/utils" ]; then
            # Ensure OLD_FILE_DIR exists
            if [ ! -d "${OLD_FILE_DIR}" ]; then
                create_old_file_dir
            fi
            move_existing_file "${HOME}/utils" "${OLD_FILE_DIR}"
        fi
        
        create_symlink "${DIR}/utils" "${HOME}/utils"
    else
        log_warn "utils directory not found in ${DIR}, skipping symlink creation"
    fi
    
    return 0
}

copy_all_files () {
    log_debug "Ensuring ${OLD_FILE_DIR} exists and creating if it does not"
    create_old_file_dir
    log_info "Copying all dot files"

    # Find the dot files in any subdirectory
    find "${DIR}" -type f -name ".*" ${EXCLUDED_FILES_ARGS} -not -path "*/.git/*" | while IFS= read -r FILE; do
        FILENAME=$(basename "${FILE}")
        move_existing_file "${HOME}/${FILENAME}" "${OLD_FILE_DIR}"
        create_symlink "${FILE}" "${HOME}/${FILENAME}"
        
        # Special handling for .applets file
        if [ "${FILENAME}" = ".applets" ]; then
            handle_applets_special_case
        fi
    done
    
    log_info "Copying machine specific config file"
    # Copy machine_local.template to ${HOME}/.machine_local if it does not exist
    if [ ! -f "${HOME}/.machine_local" ]; then
        log_info "Copying ${DIR}/Shell/machine_local.template to ${HOME}/.machine_local"
        if [ "${DRY_RUN}" = true ]; then
            echo "cp ${DIR}/Shell/machine_local.template ${HOME}/.machine_local"
        else
            cp "${DIR}/Shell/machine_local.template" "${HOME}/.machine_local"
        fi
    fi
    
    # If there are one or more subdirectories of ./Shell then create directory links to them in ${HOME}
    if [ -d "${DIR}/Shell" ]; then
        log_info "Creating directory links to ${DIR}/Shell subdirectories in ${HOME}"
        find "${DIR}/Shell" -mindepth 1 -maxdepth 1 -type d ${EXCLUDED_DIRS_ARGS} | while IFS= read -r SUBDIR; do
            # Skip the applets directory as it's handled separately
            if [ "$(basename "${SUBDIR}")" = "applets" ]; then
                continue
            fi
            create_symlink "${SUBDIR}" "${HOME}/$(basename "${SUBDIR}")"
        done
    fi
    
    # Source the shell rc file
    source_shell_rc
    return 0
}

copy_selected_file () {
    # Handle the file name passed in and if not file name is passed return an error
    if [ -z "${COPY_FILE}" ]; then
        log_error "No file name passed in, returning"
        log_info "Use -l to list available files"
        return 1
    fi
    log_info "Ensuring ${OLD_FILE_DIR} exists and creating if it does not"
    create_old_file_dir
    log_info "Copying ${COPY_FILE}"
    # Search the parent directory of this script and all subdirectories for the file name passed in
    FILE=$(find "${DIR}" -type f -name "${COPY_FILE}" ${EXCLUDED_FILES_ARGS} ${EXCLUDED_DIRS_ARGS})
    if [ -z "${FILE}" ]; then
        log_error "File ${COPY_FILE} not found"
        return 1
    fi
    
    # If the file is found then move the existing file to the OLD_FILE_DIR and create a symlink to the new file
    FILENAME=$(basename "${FILE}")
    move_existing_file "${HOME}/${FILENAME}" "${OLD_FILE_DIR}"
    create_symlink "${FILE}" "${HOME}/${FILENAME}"
    
    # Special handling for .applets file
    if [ "${FILENAME}" = ".applets" ]; then
        handle_applets_special_case
    fi
    
    # If the file copied is a shell rc file then source it by calling source_shell_rc
    if [[ "${FILENAME}" =~ ^\..*rc$ ]]; then
        source_shell_rc
    fi
    return 0
}

main "${@}"