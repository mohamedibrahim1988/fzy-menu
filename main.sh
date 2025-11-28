#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_PICKER="${TMUX_PICKER:-fzy}"
TMUX_PICKER_OPTIONS="${TMUX_PICKER_OPTIONS:--l 20 -p Choose}"
TMUX_PICKER_LIST="${TMUX_PICKER_LIST:-Sessions|Window|pane|keybind}"

# Convert pipe-separated list to newline-separated
items_origin=$(echo "$TMUX_PICKER_LIST" | tr '|' '\n')
items_origin+=$'\nCancel'

item=$(echo "${items_origin}" | $TMUX_PICKER $TMUX_PICKER_OPTIONS)
[[ "$item" == "Cancel" || -z "$item" ]] && exit

# Execute the selected script
"$CURRENT_DIR/scripts/${item}.sh"
