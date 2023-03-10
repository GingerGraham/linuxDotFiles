# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="jonathan"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 7 

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	aliases
	git
	#git-auto-fetch
	#git-extras
	#gitfast
	#git-flow
	#git-flow-avh
	#gitignore
	#git-prompt
	#jsontools
	kubectl
	#python
	#ssh-agent
	terraform
	#tmux
	#ufw
	#vim-interaction
	#vscode
	z
	zsh-autosuggestions
	zsh-syntax-highlighting
	)

source $ZSH/oh-my-zsh.sh

# User configuration

# Customising ZSH Autosuggestion
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#c6c6c6"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

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

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

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

# If OS is Mac then load the apple keychain for SSH
if [[ ${OS} == "Mac" ]]; then
	ssh-add --apple-load-keychain
fi

# If WSL is true and keychain is installed then load the keychain
if [[ "${WSL}" = true ]] && command -v keychain &> /dev/null; then
	if [[ ! -z "${HOSTNAME}" ]]; then
		source ${HOME}/.keychain/${HOSTNAME}-sh
	elif [[ ! -z "${HOST}" ]]; then
		source ${HOME}/.keychain/${HOST}-sh
	elif [[ ! -z "${NAME}" ]]; then
		source ${HOME}/.keychain/${NAME}-sh
	else
		echo "Unable to load keychain"
	fi
fi

# if [[ "${WSL}" = true ]]; then
# 	if command -v keychain &> /dev/null; then
# 		source ${HOME}/.keychain/${HOSTNAME}-sh
# 	fi
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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
