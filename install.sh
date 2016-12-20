#! /usr/bin/env sh

dotfiles="$HOME/.dotfiles"

ln -s "$dotfiles/ctags" "$HOME/.ctags" > /dev/null 2>&1
ln -s "$dotfiles/vimrc" "$HOME/.vimrc" > /dev/null 2>&1
ln -s "$dotfiles/tmux.conf" "$HOME/.tmux.conf" > /dev/null 2>&1
ln -s "$dotfiles/rtorrent.rc" "$HOME/.rtorrent.rc" > /dev/null 2>&1
ln -s "$dotfiles/bash_aliases" "$HOME/.bash_aliases" > /dev/null 2>&1
ln -s "$dotfiles/npmrc" "$HOME/.npmrc" > /dev/null 2>&1
# ln -s "$dotfiles/ycm_extra_conf.py" "$HOME/.ycm_extra_conf.py" > /dev/null 2>&1
ln -s "$dotfiles/gitconfig" "$HOME/.gitconfig" > /dev/null 2>&1
ln -s "$dotfiles/inputrc" "$HOME/.inputrc" > /dev/null 2>&1
ln -s "$dotfiles/bashrc" "$HOME/.bashrc" > /dev/null 2>&1
