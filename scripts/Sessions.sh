#!/bin/bash
TMUX_PICKER="${TMUX_PICKER:-fzy}"
TMUX_PICKER_OPTIONS="${TMUX_PICKER_OPTIONS:--l 20}"
if [[ -z "$1" ]]; then
    action=$(printf "switch\nnew\nrename\ndetach\nkill\nCancel" | $TMUX_PICKER $TMUX_PICKER_OPTIONS -p "Select an action:")
else
    action="$1"
fi
sessions=$(tmux list-sessions -F "#S")
[[ -z "$action" || "$action" == "Cancel" ]] && exit 0
# === ACTION HANDLERS ===
if [[ "$action" == "switch" ]]; then
    selected=$(echo -e "$sessions\nCancel" | $TMUX_PICKER $TMUX_PICKER_OPTIONS -p 'Select session:')
    [[ "$selected" == "Cancel" || -z "$selected" ]] && exit 0
    if [[ -n "$selected" ]]; then
        tmux switch-client -t "$selected"
    fi
elif [[ "$action" == "new" ]]; then
    echo -n "Enter name for new session: "
    read -r name
    [[ -z "$name" ]] && exit 0
    tmux new-session -d -s "$name" && tmux switch-client -t "$name"
elif [[ "$action" == "rename" ]]; then
    selected=$(echo -e "$sessions\nCancel" | $TMUX_PICKER $TMUX_PICKER_OPTIONS -p 'Select session:')
    [[ "$selected" == "Cancel" || -z "$selected" ]] && exit 0
    old_name="$selected"
    read -r -p "Enter new name for session '$old_name': " new_name
    tmux rename-session -t "$old_name" "$new_name"
elif [[ "$action" == "kill" ]]; then
    targets=$(echo -e "$sessions\nCancel" | fzy -m)
    [[ "$targets" == "Cancel" || -z "$targets" ]] && exit 0
    echo "$targets" | sort -r | xargs -I{} tmux kill-session -t "{}"
elif [[ "$action" == "detach" ]]; then
    target=$({
        session=$(tmux list-sessions | grep 'attached')
        echo -e "$session\nCancel"
    } | $TMUX_PICKER $TMUX_PICKER_OPTIONS -p "Detach session:")
    [[ -z "$target" || "$target" == "Cancel" ]] && exit 0
    tmux detach -s "$target"
fi
