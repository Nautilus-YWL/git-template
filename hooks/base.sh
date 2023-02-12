#!/usr/bin/env bash

test -d "$GIT_COMMON_DIR"/rebase-merge -o -d "$GIT_COMMON_DIR"/rebase-apply && exit 0

function find-program {
    program=$1
    command -v $program >/dev/null 2>&1 || {
        echo >&2 "\nThis repository is configured for $program but it was not found on your path.\n";
        exit 2;
    }
}
export -f find-program
