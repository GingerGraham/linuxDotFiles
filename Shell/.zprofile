#!/usr/bin/env zsh
# ~/.zprofile - executed for zsh login shells

# Set essential environment variables
export EDITOR=vim

# Add user-specific bin directories to PATH if not already present
if [[ ! ":$PATH:" == *":${HOME}/.local/bin:"* ]]; then
  PATH="${HOME}/.local/bin:${PATH}"
fi

if [[ ! ":$PATH:" == *":${HOME}/bin:"* ]]; then
  PATH="${HOME}/bin:${PATH}"
fi

# Source zshrc for login shells to ensure consistent environment
if [ -f ~/.zshrc ]; then
  source ~/.zshrc
fi