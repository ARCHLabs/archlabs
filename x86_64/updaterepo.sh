#!/usr/bin/env bash

# Repo update script using repo-add, rsync, and git
# written by Nathaniel Maia for ArchLabs, December 2017

SF_USER="$1"

readonly RPATH="$(cd "$(dirname "$0")" || exit ; pwd -P)"
readonly ARCHDIR="$(basename "$RPATH")"
readonly REPO_PATH="$(sed "s~/${ARCHDIR}~~" <<< "$RPATH")"
readonly SF_PATH="/home/frs/project/archlabs-repo/archlabs_repo/x86_64"

if ! hash rsync git &>/dev/null; then
    echo "ERROR: Script requires both rsync and git installed"
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

commit_sf() {
    if [[ $SF_USER ]]; then
        echo -e "\nUser: $SF_USER"
        cd "$REPO_PATH/$ARCHDIR" || return
        rsync -auvLPh -e ssh $(ls) "$SF_USER@frs.sourceforge.net:$SF_PATH"
    else
        printf "\nEnter Sourceforge Username: "
        read -r SF_USER
        commit_sf
    fi
}

if [[ -d $REPO_PATH/$ARCHDIR ]]; then
    commit_repo

    echo -e "\nPushing to git origin"
    commit_git

    echo -e "\nPushing to SF"
    commit_sf
else
    echo -e "\nCannot find repo directory: '$REPO_PATH/$ARCHDIR'"
    exit 1
fi

echo -e "\nRepo updated!!"
exit 0
