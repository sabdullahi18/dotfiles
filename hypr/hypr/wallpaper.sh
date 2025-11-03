#!/usr/bin/env bash

sleep 1
WALLPAPER_DIR="$HOME/dotfiles/hypr/hypr/wallpaper/"
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
