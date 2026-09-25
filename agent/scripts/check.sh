#!/bin/sh
set -eu

# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

[ -n "$manager" ] || fail "WAZUH_MANAGER is empty in .env"

printf '%s\n' "Hostname / agent name: $agent_name"
printf '%s\n' "Manager: $manager"
printf '%s\n' "Expected package: $agent_version"

if dpkg-query -W -f='${Version}\n' wazuh-agent >/dev/null 2>&1; then
    installed=$(dpkg-query -W -f='${Version}' wazuh-agent)
    printf '%s\n' "Installed package: $installed"
else
    printf '%s\n' "Installed package: not installed"
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl is-enabled wazuh-agent 2>/dev/null || true
    systemctl is-active wazuh-agent 2>/dev/null || true
fi

if [ -f /var/ossec/logs/ossec.log ]; then
    printf '\n%s\n' "Recent enrollment/connection messages:"
    grep -E 'Using agent name|Connected to the server|Requesting a key|Valid key|ERROR|WARNING' \
        /var/ossec/logs/ossec.log 2>/dev/null | tail -30 || true
fi
