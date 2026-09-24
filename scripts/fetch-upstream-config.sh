#!/bin/sh
set -eu
# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================
BASE="https://raw.githubusercontent.com/wazuh/wazuh-docker/v4.14.7/single-node/config"
fetch() {
  dest=$1
  url=$2
  [ ! -s "$dest" ] || { printf '%s\n' "KEEP: $dest"; return; }
  command -v curl >/dev/null 2>&1 || { echo "ERROR: curl is required" >&2; exit 1; }
  mkdir -p "$(dirname "$dest")"
  printf '%s\n' "FETCH: $dest"
  curl --fail --location --silent --show-error "$url" -o "$dest.tmp"
  mv "$dest.tmp" "$dest"
  # Compatibility exception: these bind-mounted configs must be readable by
  # non-root processes in the containers. Avoid hard-coding undocumented UID/GID.
  chmod 0644 "$dest"
}
fetch config/wazuh_cluster/wazuh_manager.conf "$BASE/wazuh_cluster/wazuh_manager.conf"
fetch config/wazuh_indexer/wazuh.indexer.yml "$BASE/wazuh_indexer/wazuh.indexer.yml"
fetch config/wazuh_indexer/internal_users.yml "$BASE/wazuh_indexer/internal_users.yml"
fetch config/wazuh_dashboard/opensearch_dashboards.yml "$BASE/wazuh_dashboard/opensearch_dashboards.yml"
fetch config/wazuh_dashboard/wazuh.yml "$BASE/wazuh_dashboard/wazuh.yml"
