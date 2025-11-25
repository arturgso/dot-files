#!/usr/bin/env bash

dir="$HOME/.config/rofi/launchers/type-2"
theme='style-6' 

cliphist list | rofi -dmenu -display-columns 2 -theme "${dir}/${theme}.rasi" | cliphist decode | wl-copy && sleep 0.1 && wtype -M ctrl v -m ctrl
