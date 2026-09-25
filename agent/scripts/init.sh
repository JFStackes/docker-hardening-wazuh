#!/bin/sh
set -eu

# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

umask 077

if [ -f .env ]; then
    chmod 0600 .env
    printf '%s\n' ".env already exists; it was not modified."
else
    cp .env.example .env
    chmod 0600 .env
    printf '%s\n' "Created agent-linux/.env."
fi

printf '%s\n' "Detected hostname: $(hostname -s 2>/dev/null || hostname)"
printf '%s\n' "This hostname will be used as the Wazuh agent name."
printf '%s\n' "Edit .env, then run: sudo make install"
