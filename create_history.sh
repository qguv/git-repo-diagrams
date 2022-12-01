#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

i=0
diagram_filename() {
    printf '%s/%03d.png' "$SCRIPT_DIR" "$i"
}
diagram() {
    i=$((i + 1))
    filename="$(diagram_filename)"
    sh "$SCRIPT_DIR/gen_diagram.sh" "$filename" develop
    printf 'wrote %s\n' "$filename"
}
add_arrow() {
    x1="$1"
    y1="$2"
    x2="$3"
    y2="$4"
    angle="$(python3 -c "import math; print(math.degrees(math.atan(($y2 - $y1) / ($x2 - $x1))))")"
    arrow_head="path 'M 0,0  l -15,-5  +5,+5  -5,+5  +15,-5 z'"
    mogrify \
        -stroke '#ff4444' \
        -strokewidth 6 \
        -draw "line $x1,$y1 $x2,$y2" \
        -strokewidth 1 \
        -draw "
            fill #ff4444
            translate $x2,$y2
            rotate $angle
            scale 4,4
            $arrow_head" \
        "$(diagram_filename)"
}

# set dates artificially to fix commit ordering in diagrams
t=0
isodate() {
    t=$((t + 1))
    GIT_COMMITTER_DATE="$(($t + 100000000)) +0100" "$@"
}
alias git='isodate git'

repo="$(mktemp -d)"
pushd "$repo" >/dev/null

git init
git branch -m develop

git commit --allow-empty -m 'initial commit'
git commit --allow-empty -m 'update translations 1'

git switch -c stable
git commit --allow-empty -m 'prepare release v4.0.0'
git tag -am v4.0.0 v4.0.0

git switch develop
git commit --allow-empty -m 'work 1'
git cherry-pick --allow-empty v4.0.0
git commit --allow-empty -m 'work 2'
git commit --allow-empty -m 'update translations 2'

git switch -c prod
git commit --allow-empty -m 'prepare release v4.1.0'
git tag -am v4.1.0 v4.1.0

git switch develop
git commit --allow-empty -m 'work 3'
git cherry-pick --allow-empty v4.1.0
git commit --allow-empty -m 'work 4'
git commit --allow-empty -m 'update translations 3'
git branch uat
git commit --allow-empty -m 'work 5'

diagram

git switch uat
git commit --allow-empty -m 'hotfix 1'

git switch develop
git commit --allow-empty -m 'work 6'

diagram

git cherry-pick --allow-empty uat

diagram

git commit --allow-empty -m 'work 7'

diagram

# prod becomes stable
git branch -f stable prod

diagram
add_arrow 81 1076 150 770

# uat becomes prod
git switch -C prod uat

diagram
add_arrow 81 697 150 316

# create release commit on prod
git commit --allow-empty -m 'prepare release v4.2.0'
git tag -am v4.2.0 v4.2.0

diagram

# cherry-pick release commit
git switch develop
git cherry-pick --allow-empty v4.2.0

diagram

# update translations on develop
git commit --allow-empty -m 'update translations 4'

diagram

# then uat becomes develop
git branch -f uat develop

diagram
add_arrow 81 473 252 90

# now, develop can move on
git commit --allow-empty -m 'work 8'

diagram

popd >/dev/null
rm -rf "$repo"
