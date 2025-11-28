#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux bind-key -T prefix F \
    display-popup -E \
    -S fg=blue -T "#[align=centre]#[fg=blue]>>MENU<<" \
    -w 91% -h 50% "$CURRENT_DIR/main.sh"
