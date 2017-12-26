#!/usr/bin/env bash

# highlight with gray background.
_hl="\[\e[48;5;237m\]"
# reset all attributes
_reset="\[\e[0m\]"


# for use with \W in prompt.
export PROMPT_DIRTRIM=2
export GIT_PS1_STATESEPARATOR=":"
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
_prompt_command() {
    # Save the status before anything else so $? does not get overwritten.
    local EXIT=$? _status _autoenv_prompt _pwd

    if [ "$EXIT" != 0 ]; then
        _status="$EXIT "
    fi

    _autoenv
    if [ -n "$AUTOENV" ]; then
        _autoenv_prompt="${_hl}${AUTOENV_PROMPT:-env}${_reset} "
    fi

    # pwd with only last two directories and subsitute /home/$USER with ~.
    _pwd=$(awk '
        BEGIN { FS="/" }
        NF <= 2 { printf "%s", $0 }
        NF > 2 { p=sprintf("%s/%s", $(NF-1), $NF); gsub(/.*'"$USER"'/, "~", p); printf "%s", p }
    ' <<< $PWD )

    __git_ps1 "${_status}${_autoenv_prompt}" "${_hl}${_pwd}${_reset} $ " "${_hl}%s${_reset} "

    history -a  # Append new lines to history file
    history -c  # Clear the history list
    history -r  # Append the history file to the history list

    # Set the window title to $PWD
    echo -ne "\033]0;$PWD\007"
}
export PROMPT_COMMAND="_prompt_command"
