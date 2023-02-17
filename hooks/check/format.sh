#!/usr/bin/env bash

count=0
for ctx in `git diff --cached --name-only --diff-filter=ACM |git check-attr --stdin text |tr -d ' '`; do
    IFS=':' read file attr info <<< "$ctx"
    if ! [ -f "$file" ] || [ "$info" = "unset" ]; then
        continue
    fi
    case "${file##*.}" in
        c|h|cc|hh|cxx|hxx|cpp|hpp|c\+\+|h\+\+|tcc)
            clang-format --Wno-error=unknown -i "$file"
            ;;
        *)
            sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' -e 's/[[:space:]]*$//' "$file"
            ;;
    esac
    status=$?
    if [ $status -ne 0 ]; then
        : $(( count++ ))
        echo >&2 "$file: failed to format"
    else
        git add "$file"
    fi
done
exit $count
