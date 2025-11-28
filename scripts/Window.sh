#!/bin/bash
TMUX_PICKER="${TMUX_PICKER:-fzy}"
TMUX_PICKER_OPTIONS="${TMUX_PICKER_OPTIONS:--l 20}"
if [[ -z "$1" ]]; then
    action=$(printf "New\nRename\nKill\nSwap\nCancel" | $TMUX_PICKER $TMUX_PICKER_OPTIONS -p "Select an action:")
else
    action="$1"
fi
windows=$(tmux list-windows -a -F "#S:#I: #W")
[[ -z "$action" || "$action" == "Cancel" ]] && exit 0
# === ACTION HANDLERS ===
if [[ "$action" == "New" ]]; then
    read -r -p "Enter New name for window : " name
    [[ -z "$name" ]] && exit 0
    tmux new-window -n "$name" && tmux switch-client -t "$name"
elif [[ "$action" == "Rename" ]]; then
    selected=$(echo -e "$windows\nCancel" | $TMUX_PICKER $TMUX_PICKER_OPTIONS -p 'Select window:')
    [[ "$selected" == "Cancel" || -z "$selected" ]] && exit 0
    target=$(echo "$selected" | sed 's/: .*//')
    old_name="$target"
    read -r -p "Enter New name for window '$old_name': " new_name
    tmux rename-window -t "$old_name" "$new_name"
elif [[ "$action" == "Kill" ]]; then
    targets=$(echo -e "$windows\nCancel" | $TMUX_PICKER $TMUX_PICKER_OPTIONS -m -p "Select windows to kill:")
    [[ "$targets" == "Cancel" || -z "$targets" ]] && exit 0
    target=$(echo "$targets" | sed 's/: .*//')
    echo "$target" | sort -r | xargs -I{} tmux unlink-window -k -t "{}"
elif [[ "$action" == "Swap" ]]; then
    target_swap_origin=$(echo -e "$windows\nCacel" | $TMUX_PICKER $TMUX_PICKER_OPTIONS -p "Swap window")
    [[ "$target_swap_origin" == "Cancel" || -z "$target_swap_origin" ]] && exit
    target_swap=$(echo "$target_swap_origin" | sed 's/: .*//')
    tmux swap-window -s "$target" -t "$target_swap"
fi
