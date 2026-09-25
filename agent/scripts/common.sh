#!/bin/sh
set -eu

# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ENV_FILE="$ROOT_DIR/.env"

fail() {
    printf '%s\n' "ERROR: $*" >&2
    exit 1
}

require_root() {
    [ "$(id -u)" -eq 0 ] || fail "run this command as root (sudo make ...)"
}

env_value() {
    key=$1
    [ -f "$ENV_FILE" ] || return 0

    # Read a literal KEY=value line. No eval/source is used.
    sed -n "s/^${key}=//p" "$ENV_FILE" | tail -n 1
}

manager=$(env_value WAZUH_MANAGER)
registration_server=$(env_value WAZUH_REGISTRATION_SERVER)
registration_password=$(env_value WAZUH_REGISTRATION_PASSWORD)
agent_version=$(env_value WAZUH_AGENT_VERSION)

[ -n "$agent_version" ] || agent_version="4.14.7-1"
agent_name=$(hostname -s 2>/dev/null || hostname)

[ -n "$agent_name" ] || fail "could not determine hostname"
