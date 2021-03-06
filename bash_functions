#!/usr/bin/env bash

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

# c - browse chrome history
c() {
    local cols sep google_history open
    cols=$(( COLUMNS / 3 ))
    sep='{::}'

    if [ "$(uname)" = "Darwin" ]; then
        google_history="$HOME/Library/Application Support/Google/Chrome/Default/History"
        open=open
    else
        google_history="$HOME/.config/google-chrome/Default/History"
        open=xdg-open
    fi
    cp -f "$google_history" /tmp/h
    sqlite3 -separator $sep /tmp/h \
        "select substr(title, 1, $cols), url
    from urls order by last_visit_time desc" |
    awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
    fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
}

# # Fzf intergration with z
# unalias z 2> /dev/null
# z() {
# 	# If arguments are given give them to z. Otherwise use fzf.
# 	[ $# -gt 0 ] && _z "$*" && return
# 	cd "$(_z -l 2>&1 | fzf-tmux +s --tac --query "$*" | sed 's/^[0-9,.]* *//')" || exit
# }

# Serve a directory.
# param: dir (not required)
# option -p: port (not required)
serve() {
	local port
	if [ "$1" = "-p" ]; then
		port="$2"
		shift 2
	fi

    # This makes it easier to open the link.
    echo Will serve HTTP on http://0.0.0.0:${port:-8000} ...
	(cd "${1:-$PWD}" && python3 -m http.server "${port:-8000}" > /dev/null)
}

mkcd () {
	mkdir -p "./$1" && cd "./$1" || exit
}

pyclean () {
    find . -name *.pyc -type f -delete
    find . -name __pycache__ -type d -delete
}

vclean () {
    find $HOME/.vim/tmp -type f -delete
}

_get_hotpluggable_devices () {
    lsblk --output HOTPLUG,TYPE,NAME,MODEL,MAJ:MIN,MOUNTPOINT --path --raw | \
    awk -F '[ ]' '
        $1 != 1 { next }
        $2 == "disk" {
            gsub(/\\x20/,"",$4)
            name=tolower($4);
        }
            $2 == "part" && $6 == "" {
            sub(":","",$5);
            mntpnt="/media/"name$5;
            printf "%s %s\n", $3, mntpnt
        }'
}
_get_mounted_hotpluggable_devices () {
    pmount | head -n-1 | tail -n+2 | awk '{ printf "%s %s\n", $1, $3 }'
}

mnt () {
    local devices=$(_get_hotpluggable_devices)
    if [ -n "$1" ]; then
        devices=$(grep "$1" <<< $devices)
    fi

    if [ -n "$devices" ]; then
        while read -r device; do
            pmount $device && notify-send "Drive mounted" "$device"
        done <<< "$devices"
    fi
}

_mnt () {
    local options=$(_get_hotpluggable_devices)
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "$options" -- $cur) )
}
complete -F _mnt mnt

umnt () {
    local mountpoint mounted=$(_get_mounted_hotpluggable_devices)
    if [ -n "$1" ]; then
        mounted=$(grep "$1" <<< $mounted)
    fi

    if [ -n "$mounted" ]; then
        while read -r d; do
            mountpoint=$(cut -f2 -d ' ' <<< $d)
            pumount $mountpoint && notify-send "Drive unmounted" $mountpoint
        done <<< "$mounted"
    fi
}

_umnt () {
    local options=$(_get_mounted_hotpluggable_devices)
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "$options" -- $cur) )
}
complete -F _umnt umnt

tat () {
    tmux attach -t $@

}
function _tat() {
    local options=$(tmux list-sessions -F '#{session_name}' 2> /dev/null)
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$options" -- "${cur}") )
}

complete -F _tat tat
