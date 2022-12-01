#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

i=0
diagram() {
    filename="$1"
    if [ -z "$filename" ]; then
        i=$((i + 1))
        filename="$(printf '%03d.png' $i)"
    fi
    sh "$SCRIPT_DIR/gen_diagram.sh" "$SCRIPT_DIR/$filename"
    printf 'wrote %s\n' "$filename"
}

repo="$(mktemp -d)"
pushd "$repo"

git init
git branch -m develop

# introduce a one-second delay after commits, to fix commit ordering in diagrams
echo sleep 1 >> .git/hooks/post-commit
chmod u+x .git/hooks/post-commit

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

# hack: makes diagram easier to read
git branch -D prod

diagram

# uat becomes prod
git switch -C prod uat

# hack: makes diagram easier to read
git branch -D uat

diagram

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

# now, develop can move on
git commit --allow-empty -m 'work 8'

diagram

popd
rm -rf "$repo"
