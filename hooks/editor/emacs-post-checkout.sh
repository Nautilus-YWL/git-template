#!/usr/bin/env bash

if [[ $(find-program emacs >/dev/null 2>&1) -ne 0 || -f "$GIT_TOPLEVEL_DIR"/.dir-locals.el ]]; then
    exit
fi

cat <<-EOF |tee "$GIT_TOPLEVEL_DIR"/.dir-locals.el
(
 (format-all-formatters
  ("C++" clang-format "--Wno-error=unknown"))
 )
EOF
