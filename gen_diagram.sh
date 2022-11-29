#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
printf '[DEBUG] SCRIPT_DIR: %s\n' "$SCRIPT_DIR" # DEBUG
output_path="${1?output path required}"
sleep_time="${2:-0.3}"

if swaymsg -t get_tree | jq -e -f "$SCRIPT_DIR/gitg.jq" > /dev/null; then
    printf "gitg is already running, please quit it first\n" >&2
    exit 1
fi

current_branch="$(git branch --show-current)"
git switch -C delete-me
git commit -m 'delete me' --allow-empty

tmpdir="$(mktemp -d)"
XDG_CONFIG_HOME="$tmpdir" gitg --all &
sleep "$sleep_time"

swaymsg '[app_id="gitg"]' floating enable
sleep "$sleep_time"

swaymsg '[app_id="gitg"]' resize set width 300 px height 1000 px
sleep "$sleep_time"

win_pos="$(swaymsg -t get_tree | jq --raw-output -f "$SCRIPT_DIR/gitg.jq")"
x=$(( ${win_pos%%,*} + 201 ))
y=$(( ${win_pos##*,} + 72 ))
w=323
h=422
grim -g "$x,$y ${w}x${h}" -t png "$output_path"
mogrify -trim -bordercolor white -border 10 "$output_path"

swaymsg '[app_id="gitg"]' kill
rm -r "$tmpdir"
git switch "$current_branch"
git branch -D delete-me
