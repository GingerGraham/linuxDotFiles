#!/bin/bash
# .make.sh 
# This script creates symlinks from ~/ to dotfiles dir
# Forked from Wes Doyle (https;//github.com/wesdoyle/dotfiles) on 2019-10-23

dir=~/dotFiles
olddir=~/dotFiles_old
files=".bashrc .bash_aliases .vimrc .zshrc .gitconfig .tmux.conf"

echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...complete."

echo "Changing to the $dir directory"
cd $dir
echo "...complete."

for file in $files; do
    echo "Moving existing dotfiles from ~ to $olddir"
    mv ~/$file ~/dotFiles_old/ # Could this be changed to $olddir ?
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/$file
done
