# Graham Watts Dot File Install

My personal collection of dot files for Linux and MacOS installs.  The primary focus of the tools and utilities here are for tools I primarily use for DevOps and Cloud Engineering.  With some additional tools development or system administration.

Tested on MacOS and Linux.

## Pre-requisites

This collection of dot files has the following expectations and external dependencies:

- `zsh` is installed and configured as the default shell
  - This applies for MacOS and Linux
- `oh-my-zsh` is installed
  - This applies for MacOS and Linux
  - See [oh-my-zsh](https://ohmyz.sh/) for more details
- Some plugins for `oh-my-zsh` are also expected by `.zshrc`
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
  - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

If `zsh` is not installed then most of the files here are not used as only the `.zshrc` files supplied is configured to use them, the same configurations are not contained in the `.bashrc` files.

## Installation

Installation on the available dot files is completed using the `installDotFiles.sh` script

### Output Directory

If no alternative output directory is specified then `~/.oldDotFiles` is used.

If an output directory is specified that the script will confirm if the directory exists and if not, create it.

### Basic Usage

Simply run the script from the local directory `./installDotFiles.sh`

```bash
# Example running the help output

$ ./installDotFiles.sh -h

Version 2.0.2

Purpose: This script creates symlinks from ~/ to a dotfiles directory cloned from github

Usage: installDotFiles.sh [-a] [-d] [-f <file>] [-h] [-l] [-o <dir>]

  -a  Copy all dot files
  -d  Dry run
  -f  Copy file <file>
  -h  Display this help message
  -l  List available files
  -o  Use <dir> for existing dot files
```

### Dry Run

The dry run option will output the changes that would happen and the commands that would be run to complete the actions.

```bash
# Example copying the .alias file but run using dry run

$ ./installDotFiles.sh -f .alias -d
Dry run
Ensuring /Users/gwatts/.oldDotFiles exists and creating if it does not
Copying .alias
Moving existing .alias from ~ to /Users/gwatts/.oldDotFiles if it exists
mv ~/.alias /Users/gwatts/.oldDotFiles
Creating symlink to .alias in home directory.
ln -s /Users/gwatts/Development/Personal/GitHub/linuxDotFiles/.alias ~/.alias
```

## OS Support

The following OS's are supported

- Linux
- MacOS

### OS Specific Commands

The various add-on scripts included here such as `.alias` or `.applets` have been developed with `if` based filters to filter for OS and where appropriate specific commands within the OS before applying their configuration.  Future development should follow this pattern too.

Within `.zshrc` is a small OS detection function which will detect the OS based on the `uname` command and set the `OS` variable to the OS name.  This can then be used in the various scripts to filter for OS.
