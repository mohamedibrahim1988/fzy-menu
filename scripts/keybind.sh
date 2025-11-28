#!/bin/bash

target=$(tmux list-keys | sed '1s/^/[cancel]\n/' | awk '{ $1=$2=$3=""; print $0 }' | sed 's/^ *//' | fzy -p 'Key List ' -l 25)

[[ "$target" == "[cancel]" || -z "$target" ]] && exit
echo "$target" | xargs tmux
