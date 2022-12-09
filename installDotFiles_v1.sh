#!/bin/sh
# This script creates symlinks from ~/ to a dotfiles directory cloned from github
# Github source is https://github.com/GingerGraham/linuxDotFiles
# Forked from Wes Doyle (https://github.com/wesdoyle/dotfiles) on 2019-10-23

# This script accepts 1 input parameter of an alternate directory for previously exists dot files in
# place of olddir (default value)

# Variables for script use
input=$1
dir=$PWD
olddir=~/.oldDotFiles # Default value, replace with $input if valid

if [ -d $input ]
then
	$olddir=$input
else
	echo "Directory $input does not exist, using $olddir for existing dot files"
fi

echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...complete."

echo "Changing to the $dir directory"
cd $dir
echo "...complete."

for file in $(find $dir -type f -name ".*" -exec basename {} \;);
do
	if [ $file != ".gitignore" ]
	then
		 echo "Moving existing dotfiles from ~ to $olddir"
	     mv ~/$file $olddir
         echo "Creating symlink to $file in home directory."
	     ln -s $dir/$file ~/$file
	fi
done

# TODO move this to a new script to install zsh, oh-my-zsh and then deploy this
ln -s $dir/gw-agnoster.zsh-theme ~/.oh-my-zsh/themes/gw-agnoster.zsh-theme
