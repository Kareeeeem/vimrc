#!/usr/bin/bash
alias vim='nvim'
alias vi='vim'
alias evim='vim $HOME/.dotfiles/vimrc'
alias ebash='vim $HOME/.dotfiles/{bashrc,profile,bash_aliases,prompt,bash_functions}'
alias ssh='TERM=screen-256color ssh'
alias localip="ip addr show eth0 | grep -Po 'inet \K[\d.]+'"

alias clip="clip.exe"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias la='ls -FLAH --group-directories-first' # A Hidden files, ignore . and ..
alias l='ls -lhF --group-directories-first'
#            ├l long listing
#            ├─h human readable sizes
#            └──F classifiers

alias json='python3 -m json.tool'

# http://askubuntu.com/a/17279
alias rcp="rsync -ah -P"
#                 ├a equals -rlptgoD.
#                 │          ├recursive
#                 │          ├─copy symlinks,
#                 │          ├──preserve permissions
#                 │          ├───preserve modification times
#                 │          ├────preserve group
#                 │          ├─────preserve owner (superuser only)
#                 │          └──────preserve device files and special files.
#                 └─h human readable numbers

alias rt="rtorrent"

alias tk="tmux kill-session"
alias tn="tmux new -s"
