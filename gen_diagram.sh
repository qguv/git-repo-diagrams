#!/bin/sh
set -e
output_path="${1?output path required}"
sleep_time="${2:-0.3}"

resolution_multiplier=3
gitg_default_w=660
gitg_default_h=556
crop_topleft_x=206
crop_topleft_y=76
crop_bottomright_x=610
crop_bottomright_y=501

current_branch="$(git branch --show-current)"
git switch -C delete-me develop
git commit -m 'delete me' --allow-empty

# create virtual display
gitg_w=$(($gitg_default_w * $resolution_multiplier))
gitg_h=$(($gitg_default_w * $resolution_multiplier))
Xvfb :1 -screen 0 ${gitg_w}x${gitg_h}x24 &
xvfb_pid="$!"

# create empty dconf configuration
empty_conf="$(mktemp -d)"
mkdir "$empty_conf/dconf"

# start gitg in virtual display
env -i \
    HOME="$empty_conf" \
    USER="$USER" \
    DISPLAY=":1" \
    GDK_SCALE=$resolution_multiplier \
    gitg --all &
gitg_pid="$!"

sleep "$sleep_time"

# take screenshot
import -display :1 -window root "$output_path"

# kill processes
kill "$gitg_pid"
kill "$xvfb_pid"
rm -r "$empty_conf"

# crop, trim, and add border
w=$(($resolution_multiplier * ($crop_bottomright_x - $crop_topleft_x)))
h=$(($resolution_multiplier * ($crop_bottomright_y - $crop_topleft_y)))
x=$(($resolution_multiplier * $crop_topleft_x))
y=$(($resolution_multiplier * $crop_topleft_y))
geometry="${w}x${h}+${x}+${y}"
mogrify \
    -crop $geometry \
    -trim \
    -bordercolor white -border 10 \
    "$output_path"

git switch "$current_branch"
git branch -D delete-me
