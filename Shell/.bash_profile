#!/usr/bin/env bash
# ~/.bash_profile - executed for login shells

# Set essential environment variables
export EDITOR=vim

# Add user-specific bin directories to PATH if not already present
if [[ ! ":$PATH:" == *":${HOME}/.local/bin:"* ]]; then
  PATH="${HOME}/.local/bin:${PATH}"
fi

if [[ ! ":$PATH:" == *":${HOME}/bin:"* ]]; then
  PATH="${HOME}/bin:${PATH}"
fi

# Source bashrc for login shells to ensure consistent environment
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi