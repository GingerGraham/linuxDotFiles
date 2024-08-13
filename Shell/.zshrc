# Set up the prompt
autoload -Uz promptinit
promptinit
prompt elite2 green

if [[ -f ~/.profile ]]; then
	# echo "[DEBUG] Sourcing .profile"
	source ~/.profile
fi
