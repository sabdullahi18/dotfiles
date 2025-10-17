#!/usr/bin/env bash

sleep 1
WALLPAPER_DIR="$HOME/Pictures/wallpaper/"
CURRENT_WALL=$(hyprctl hyprpaper listloaded)
FOCUSED_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)
hyprctl hyprpaper reload "$FOCUSED_MONITOR","$WALLPAPER"
