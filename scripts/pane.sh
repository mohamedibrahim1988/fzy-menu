#!/bin/bash

TMUX_PICKER="${TMUX_PICKER:-fzy}"
TMUX_PICKER_OPTIONS="${TMUX_PICKER_OPTIONS:--l 20}"

get_panes() {
    tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}  [#{pane_current_command}]"
}
# Get action selection
if [[ -z "$1" ]]; then
    selected=$(echo -e "Kill\nBreak\nLayout\nCancel" | $TMUX_PICKER $TMUX_PICKER_OPTIONS -p "Select an action:")
else
    selected="$1"
fi
[[ -z "$selected" || "$selected" == "Cancel" ]] && exit 0
# Execute the selected action
if [[ "$selected" == "Kill" ]]; then
    panes=$(get_panes)
    targets=$(printf "%s\n" "$panes" "Cancel" | $TMUX_PICKER $TMUX_PICKER_OPTIONS -p "Select panes to kill" -m)

    [[ -z "$targets" ]] && exit 0

    # Process each target to extract just the pane identifier
    echo "$targets" | while IFS= read -r target; do
        [[ "$target" == "Cancel" ]] && continue
        # Extract the pane identifier (everything before the first space)
        echo "${target%% *}"
    done | sort -r | xargs -I{} tmux kill-pane -t {}
elif [[ "$selected" == "Break" ]]; then
    # Get target pane for breaking
    panes=$(get_panes)
    target=$(echo -e "$panes\nCancel" | $TMUX_PICKER $TMUX_PICKER_OPTIONS -p "${selected,,} Pane")
    [[ -z "$target" || "$target" == "Cancel" ]] && exit 0
    target_pane=$(echo "$target" | awk '{print $1}')
    cur_ses=$(tmux display-message -p '#{session_name}')
    last_win_num=$(tmux list-windows -F '#{window_index}' | sort -nr | head -1)
    last_win_num_after=$((last_win_num + 1))
    tmux break-pane -s "$target_pane" -t "$cur_ses":"$last_win_num_after"

elif [[ "$selected" == "Layout" ]]; then
    # Layout selection - directly choose layout without pane selection
    target_origin=$(printf "even-horizontal\neven-vertical\nmain-horizontal\nmain-vertical\ntiled\nCancel" | $TMUX_PICKER $TMUX_PICKER_OPTIONS -p "Select layout:")
    [[ "$target_origin" == "Cancel" || -z "$target_origin" ]] && exit
    tmux select-layout "$target_origin"
fi
