#!/usr/bin/env bash

# Path: .profile
# Purpose: Configure the shell environment - intended to be agnostic of bash or zsh, not designed to work with shells other than bash or zsh
# Use: Sourced by .bashrc or .zshrc

# shellcheck source=/dev/null

CURRENT_SHELL="$(ps -p $$ | tail -1 | awk '{print $NF}')"

# Checking what OS we're running on and setting a variable accordingly
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     OS=Linux;;
    Darwin*)    OS=Mac;;
    CYGWIN*)    OS=Cygwin;;
    MINGW*)     OS=MinGw;;
    *)          OS="UNKNOWN:${unameOut}"
esac
# echo "Operating System is: ${OS}" # Debugging

# Detect if the OS is running in WSL
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
    # WSL
    export WSL=true
else
    # Not WSL
    export WSL=false
fi

# Test which editor(s) are available and set a variable $PREFFERED_EDITOR based on the preference order vim, vi, nano
if command -v vim &> /dev/null; then
	PREFFERED_EDITOR="vim"
elif command -v vi &> /dev/null; then
	PREFFERED_EDITOR="vi"
elif command -v nano &> /dev/null; then
	PREFFERED_EDITOR="nano"
else
	PREFFERED_EDITOR="vim"
fi

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR=${PREFFERED_EDITOR}
else
  export EDITOR=${PREFFERED_EDITOR}
fi

# If OS is Mac test if iTerm2 is installed and if so, load the shell integration
if [ "${OS}" = "Mac" ]; then
	test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi

# Adding aliases
if [[ -f ~/.alias ]]; then
  source ~/.alias
fi

# Adding node.js / nvm
if [[ -f ~/.nvm/nvm.sh ]]; then
  source ~/.node
fi

# Adding path variables
if [[ -f ~/.pathVars ]]; then
  source ~/.pathVars
fi

# Adding applets
if [[ -f ~/.applets ]]; then
  source ~/.applets
fi

# Adding tasks
if [[ -f ~/.tasks ]]; then
	source ~/.tasks
fi

# Adding machine specific configuration
if [[ -f ~/.machine_local ]]; then
  source ~/.machine_local
fi

if [ -f ~/.asdf/asdf.sh ]; then
  source ~/.asdf/asdf.sh
fi

# Confirm the user SHELL and if it is zsh then source the .zsh_profile file or if it is bash then source the .bash_profile file
if [[ "${CURRENT_SHELL}" == "zsh" ]]; then
  # Test if asdf is installed and if so load and configure it
  # if [[ -d "${HOME}/.asdf" ]]; then
    # if [[ ! "${fpath[*]}" =~ ${ASDF_DIR}/completions ]]; then
    #   fpath=("${ASDF_DIR}/completions" "${fpath}")
    # fi
  # fi
  # echo "$(date +'%Y-%m-%d %H:%M:%S.%3N') [DEBUG] Sourcing .zsh_profile"
  source "${HOME}/.zsh_profile"
elif [[ "${CURRENT_SHELL}" == "bash" ]]; then
  # Test if asdf is installed and if so load and configure it
  if [ -f ~/.asdf/asdf.sh ]; then
    source ~/.asdf/completions/asdf.bash
  fi
  # echo "$(date +'%Y-%m-%d %H:%M:%S.%3N') [DEBUG] Sourcing .bash_profile"
  source "${HOME}/.bash_profile"
fi

# If bat is installed set the BAT_THEME to Visual Studio Dark+ if it's not already set.
if command -v bat &> /dev/null; then
  if [[ -z $BAT_THEME ]]; then
    export BAT_THEME="Visual Studio Dark+"
  fi
fi
