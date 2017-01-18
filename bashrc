# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored manpages with max width 80
export MANWIDTH=80
# man() {
# 	env \
# 		LESS_TERMCAP_mb="$(printf "\e[1;34m")" \
# 		LESS_TERMCAP_md="$(printf "\e[1;34m")" \
# 		LESS_TERMCAP_me="$(printf "\e[0m")" \
# 		LESS_TERMCAP_se="$(printf "\e[0m")" \
# 		LESS_TERMCAP_so="$(printf "\e[7m")" \
# 		LESS_TERMCAP_ue="$(printf "\e[0m")" \
# 		LESS_TERMCAP_us="$(printf "\e[1;36m")" \
# 			man "$@"
# }

# no duplicates or lines starting with space
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=5000
HISTFILESIZE=100000

shopt -s histappend		# append to history file, don't overwrite it
shopt -s checkwinsize	# update the values of LINES and COLUMNS.
shopt -s globstar		# ** matches all files and 0 or more (sub)directories
shopt -s autocd			# cd without typing cd
shopt -s cmdhist		# save multiline commands as one
stty -ixon				# Disable START/STOP signals

# enable bash completion in interactive shells
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# PROMPT STUFF

PROMPT_BOLD='\[\e[1m\]'
PROMPT_UNDERLINE='\[\e[4m\]'
PROMPT_RESET='\[\e[0m\]'

# we're setting the prompt command so his needs to be done manually.
_virtualenv_prompt() {
	if [ -n "$VIRTUAL_ENV" ]; then
		echo -n "$PROMPT_BOLD$(basename "$VIRTUAL_ENV")$PROMPT_RESET "
	fi
}

# show last status if not 0. http://stackoverflow.com/a/16715681
_status_prompt() {
	local EXIT
	EXIT=$?
	if [ $EXIT != 0 ]; then
		echo -n "$PROMPT_BOLD$EXIT$PROMPT_RESET "
	fi
}

# show branch (underlined if dirty), and number of stashes.
_git_prompt() {
	local prompt

	ref=$(git symbolic-ref -q HEAD 2> /dev/null || \
		git name-rev --name-only --no-undefined --always HEAD 2> /dev/null)

	if [ -n "$ref" ]; then
		if [ -n "$(git status --porcelain 2> /dev/null)" ]; then
			prompt=$PROMPT_UNDERLINE
		fi
		prompt+=$PROMPT_BOLD${ref#refs/heads/}$PROMPT_RESET

		if [ "$(git stash list 2> /dev/null | wc -l | tr -d ' ')" != "0" ]; then
			prompt+="$PROMPT_BOLD($st_num)$PROMPT_RESET"
		fi

		echo -n " $prompt"
	fi
}

_chroot_prompt() {
	if [ -n "$debian_chroot" ]; then
		echo -n "($debian_chroot) "
	fi
}

export PROMPT_LONG=1
# prompt toggle
pt() {
	PROMPT_LONG=$([ $PROMPT_LONG == 0 ] && echo 1 || echo 0)
}

_prompt_command() {
	if [ $PROMPT_LONG -eq 0 ]; then
		PS1="$ "
	else
		PS1=$(_status_prompt)
		PS1+=$(_chroot_prompt)
		PS1+=$(_virtualenv_prompt)
		PS1+="\W"
		PS1+=$(_git_prompt)
		PS1+=" $ "
	fi

	export PS1

	# merge history after each command
	history -a # Append new lines to history file
	history -c # Clear the history list
	history -r # Append the history file to the history list
}

export PROMPT_COMMAND="_prompt_command"

# Z https://github.com/rupa/z
[ -d "$HOME/sources/z" ] && . "$HOME/sources/z/z.sh"
# GIT Completion https://github.com/git/git/blob/master/contrib/completion/git-completion.bash
[ -f "$HOME/.dotfiles/git-completion.bash" ] && . "$HOME/.dotfiles/git-completion.bash"
# TMUX complation https://github.com/imomaliev/tmux-bash-completion
[ -f "$HOME/.dotfiles/tmux.completion.bash" ] && . "$HOME/.dotfiles/tmux.completion.bash"

# FZF
[ -f ~/.fzf.bash ] && . ~/.fzf.bash
export FZF_DEFAULT_OPTS='--no-bold --color=bw'
if hash ag; then
	export FZF_DEFAULT_COMMAND='ag -g ""'
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Open files in .viminfo with fzf
v() {
	# If arguments are given give them to vim. Otherwise use fzf.
	[ $# -gt 0 ] && vim "$*" && return

	local files
	files=$(grep '^>' ~/.viminfo | cut -c3- |
	while read -r line; do
		[ -f "${line/\~/$HOME}" ] && echo "$line"
	done | fzf-tmux -d -m -q "$*" -1) && vim ${files//\~/$HOME}
}

# Fzf intergration with z
unalias z 2> /dev/null
z() {
	# If arguments are given give them to z. Otherwise use fzf.
	[ $# -gt 0 ] && _z "$*" && return
	cd "$(_z -l 2>&1 | fzf-tmux +s --tac --query "$*" | sed 's/^[0-9,.]* *//')"
}

# Switch to tmux session with FZF.
tt() {
	local client
	# If arguments are given give them to z. Otherwise use fzf.
	if [ $# -gt 0 ]; then
		client="$*"
	else
		client="$(tmux ls | grep -o "^[^:]*" | fzf-tmux --tac +s)"
	fi

	if [ -z $TMUX ]; then
		tmux a -t $client
	else
		tmux switch-client -t $client
	fi
}

ts() {
	local target
	if [ -z $1 ]; then
		TMUX= tmux a -t $1 2> /dev/null && return
		target="-s $1"
	fi

	if [ -z $TMUX ]; then
		tmux a -t $1 2> /dev/null && return
		tmux new-session -s $1
	else
		tmux new-session -d -s $1 2> /dev/null
		tmux switch-client -t $1
	fi

	TMUX= tmux new-session -d "$target" # && tmux switch-client $target
}


# Serve a directory.
serve() {
	PORT="${1:-8000}"
	cd "$1" && python -m SimpleHTTPServer "$PORT"
}

mkcd () {
	mkdir -p "./$1" && cd "./$1"
}

. ~/.bash_aliases
