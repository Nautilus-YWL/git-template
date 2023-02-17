#!/usr/bin/env bash

export GIT_TOPLEVEL_DIR=$(git rev-parse --show-toplevel)
export GIT_COMMON_DIR=$(git rev-parse --git-common-dir)
export CURRENT_BRANCH=$(git branch --show-current) # git 2.22+
# export CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
export PROTECTED_BRANCH='^(master|dev|release-*|patch-*)'
export FORCE_PUSH_CMD='force|delete|-f'

test -d "$GIT_COMMON_DIR"/rebase-merge -o -d "$GIT_COMMON_DIR"/rebase-apply && exit 0

function find-program {
    program=$1
    command -v $program >/dev/null 2>&1 || {
        echo >&2 "\nThis repository is configured for $program but it was not found on your path.\n";
        exit 2;
    }
}
export -f find-program

function prompt-to-confirm {
    local status=0
    exec </dev/tty
    while true; do
        read -r -p "Are you sure want to continue? [Y/n] " input
        case $input in
            [Yy][Ee][Ss]|[Yy])
                break;;
            [Nn][Oo]|[Nn])
                local status=1
                break;;
            *)
        esac
    done
    exec 0<&-
    return $status
}
export -f prompt-to-confirm
