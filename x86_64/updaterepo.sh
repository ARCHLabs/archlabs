#!/usr/bin/env bash

# Repo update script using repo-add and git
# written by Nathaniel Maia for ArchLabs, December 2017

readonly RPATH="$(cd "$(dirname "$0")" || exit ; pwd -P)"
readonly ARCHDIR="$(basename "$RPATH")"
readonly REPO_PATH="$(sed "s~/${ARCHDIR}~~" <<< "$RPATH")"

if ! hash git &>/dev/null; then
    echo "ERROR: Script requires git installed"
    exit 1
fi

commit_repo() {
    cd "$REPO_PATH/$ARCHDIR" || return
    rm -f archlabs_repo.*
    repo-add archlabs_repo.db.tar.gz ./*.pkg.tar.xz
    rm -f archlabs_repo.db
    cp -f archlabs_repo.db.tar.gz archlabs_repo.db
}

commit_git() {
    if [[ -e $HOME/.gitconfig ]]; then
        cd "$REPO_PATH" || return
        git add .
        git commit -m "Repo update $(date +%a-%D)"
        git push origin master
    else
        echo
        echo "ERROR: You must setup git to use this"
        exit 1
    fi
}

if [[ -d $REPO_PATH/$ARCHDIR ]]; then
    commit_repo
    echo -e "\nPushing to git origin"
    commit_git
else
    echo -e "\nCannot find repo directory: '$REPO_PATH/$ARCHDIR'"
    exit 1
fi

echo -e "\nRepo updated!!"
exit 0
