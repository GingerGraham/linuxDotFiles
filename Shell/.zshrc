#!/usr/bin/env zsh
# ~/.zshrc - executed for interactive zsh shells

# shellcheck source=/dev/null

# Sourcing standard logging library
source "${HOME}/utils/logging.sh"

# Initial logging
init_logger --color

log_debug "Running .zshrc"

if [[ -f ${HOME}/.shell_common ]]; then
	log_debug "Sourcing .shell_common"
	source ${HOME}/.shell_common
fi

# Set up the prompt
autoload -Uz promptinit
promptinit
prompt elite2 green

# Setup history
log_debug "Setting up history"
HISTSIZE=10000
SAVEHIST=${HISTSIZE}
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_verify

# Use modern completion system
log_debug "Setting up completion system"
autoload -Uz compinit
compinit

# Setting completion styles
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# FZF configuration
if command -v fzf &> /dev/null; then
	log_debug "Sourcing fzf"
  source <(fzf --zsh)
fi

# ZSH Autosuggestions configuration
if [[ -d "${HOME}/.zsh/zsh-autosuggestions" ]]; then
	log_debug "Sourcing zsh-autosuggestions from ${HOME}/.zsh/zsh-autosuggestions"
  source "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#c6c6c6"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
elif [[ -d /usr/share/zsh-autosuggestions ]]; then
	log_debug "Sourcing zsh-autosuggestions from /usr/share/zsh-autosuggestions"
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#c6c6c6"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
elif [[ -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
	log_debug "Setting up zsh-autosuggestions from oh-my-zsh"
	# source "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#c6c6c6"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# ZSH Syntax Highlighting
if [[ -d "${HOME}/.zsh/zsh-syntax-highlighting" ]]; then
	log_debug "Sourcing zsh-syntax-highlighting from ${HOME}/.zsh/zsh-syntax-highlighting"
  source "${HOME}/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -d /usr/share/zsh-syntax-highlighting ]]; then
	log_debug "Sourcing zsh-syntax-highlighting from /usr/share/zsh-syntax-highlighting"
  source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
	log_debug "Setting up zsh-syntax-highlighting from oh-my-zsh"
	source "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
fi
