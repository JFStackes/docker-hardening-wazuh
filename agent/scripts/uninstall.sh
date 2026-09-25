#!/bin/sh
set -eu

# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

require_root

printf '%s\n' "This removes the wazuh-agent package but preserves /var/ossec unless the package manager removes it."
printf '%s\n' "It does NOT delete the agent entry from the Wazuh manager."
printf '%s\n' "Run manually if this destructive action is intended:"
printf '%s\n' "  apt-mark unhold wazuh-agent"
printf '%s\n' "  apt-get remove wazuh-agent"
exit 1
