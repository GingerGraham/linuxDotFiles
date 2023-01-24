# Graham Watts Dot File Install

My personal collection of dot files for Linux and MacOS installs

## Installation

Installation on the available dot files is completed using the `installDotFiles.sh` script

### Output Directory

If not alternative output directory is specified then `~/.oldDotFiles` is used.

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
