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

[ -n "$manager" ] || fail "WAZUH_MANAGER is empty in .env"
[ "$manager" != "CHANGE_ME_MANAGER_IP_OR_DNS" ] || fail "configure WAZUH_MANAGER in .env"

if [ -z "$registration_server" ] || [ "$registration_server" = "CHANGE_ME_MANAGER_IP_OR_DNS" ]; then
    registration_server=$manager
fi

case "$agent_name" in
    localhost|localhost.localdomain)
        fail "hostname '$agent_name' is not suitable as a unique Wazuh agent name"
        ;;
esac

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    fail "/etc/os-release not found"
fi

case "${ID:-}" in
    debian|ubuntu) ;;
    *) fail "this installer supports Debian/Ubuntu only (detected: ${ID:-unknown})" ;;
esac

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl gnupg apt-transport-https

install -d -m 0755 /usr/share/keyrings
tmp_key=$(mktemp)
trap 'rm -f "$tmp_key"' EXIT HUP INT TERM

curl --fail --silent --show-error \
    https://packages.wazuh.com/key/GPG-KEY-WAZUH \
    -o "$tmp_key"

gpg --batch --yes --dearmor \
    -o /usr/share/keyrings/wazuh.gpg \
    "$tmp_key"
chmod 0644 /usr/share/keyrings/wazuh.gpg

cat > /etc/apt/sources.list.d/wazuh.list <<'EOF'
deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main
EOF
chmod 0644 /etc/apt/sources.list.d/wazuh.list

apt-get update

if ! apt-cache madison wazuh-agent | awk '{print $3}' | grep -Fxq "$agent_version"; then
    printf '%s\n' "Available wazuh-agent versions:" >&2
    apt-cache madison wazuh-agent >&2 || true
    fail "wazuh-agent version '$agent_version' is not available from the configured repository"
fi

current_version=$(dpkg-query -W -f='${Version}' wazuh-agent 2>/dev/null || true)

if [ -n "$current_version" ] && [ "$current_version" != "$agent_version" ]; then
    fail "wazuh-agent $current_version is already installed; refusing automatic version replacement with $agent_version"
fi

if [ -z "$current_version" ]; then
    printf '%s\n' "Installing wazuh-agent $agent_version"
    printf '%s\n' "Agent name: $agent_name"
    printf '%s\n' "Manager: $manager"

    if [ -n "$registration_password" ]; then
        WAZUH_MANAGER="$manager" \
        WAZUH_REGISTRATION_SERVER="$registration_server" \
        WAZUH_REGISTRATION_PASSWORD="$registration_password" \
        WAZUH_AGENT_NAME="$agent_name" \
        apt-get install -y "wazuh-agent=$agent_version"
    else
        WAZUH_MANAGER="$manager" \
        WAZUH_REGISTRATION_SERVER="$registration_server" \
        WAZUH_AGENT_NAME="$agent_name" \
        apt-get install -y "wazuh-agent=$agent_version"
    fi
else
    printf '%s\n' "wazuh-agent $agent_version is already installed; package installation skipped."
fi

# Prevent accidental upgrades beyond the manager version.
apt-mark hold wazuh-agent >/dev/null

systemctl daemon-reload
systemctl enable wazuh-agent >/dev/null
systemctl restart wazuh-agent

printf '%s\n' "OK: wazuh-agent service started."
printf '%s\n' "Agent name: $agent_name"
printf '%s\n' "Package: wazuh-agent $agent_version"
printf '%s\n' "The package is held to prevent unintended upgrades."
