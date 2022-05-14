#!/bin/bash


string="$(cat ~/.zshrc | grep "^ZSH_THEME")"
substring="$(cat ~/.zshrc | grep "^ZSH_THEME" | cut -d '=' -f 2)"
repl=\"$1\"

newstring=$(echo ${string/$substring/"$repl"})

sed -i "s/$string/$newstring/g" ~/.zshrc

cat ~/.zshrc | grep "^ZSH_THEME"
source ~/.zshrc
