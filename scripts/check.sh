#!/bin/sh
set -eu
# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================
compose_only=0
[ "${1:-}" = "--compose-only" ] && compose_only=1
command -v docker >/dev/null 2>&1 || { echo "ERROR: docker not found" >&2; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "ERROR: docker compose unavailable" >&2; exit 1; }
[ -f .env ] || { echo "ERROR: .env missing; run make init" >&2; exit 1; }
for f in config/wazuh_cluster/wazuh_manager.conf config/wazuh_indexer/wazuh.indexer.yml config/wazuh_indexer/internal_users.yml config/wazuh_dashboard/opensearch_dashboards.yml config/wazuh_dashboard/wazuh.yml; do
  [ -s "$f" ] || { echo "ERROR: missing upstream config $f; run make init" >&2; exit 1; }
done
docker compose -f compose.yaml config --quiet
echo "OK: docker compose config --quiet"
[ "$compose_only" -eq 1 ] && exit 0
dir=config/wazuh_indexer_ssl_certs
required="root-ca.pem root-ca-manager.pem wazuh.manager.pem wazuh.manager-key.pem wazuh.indexer.pem wazuh.indexer-key.pem admin.pem admin-key.pem wazuh.dashboard.pem wazuh.dashboard-key.pem"
bad=0
for f in $required; do [ -f "$dir/$f" ] || { echo "MISSING: $dir/$f"; bad=1; }; done
[ "$bad" -eq 0 ] || { echo "ERROR: TLS files missing; run make certs" >&2; exit 1; }
vm=$(sysctl -n vm.max_map_count 2>/dev/null || echo 0)
[ "$vm" -ge 262144 ] || { echo "ERROR: vm.max_map_count=$vm; Wazuh requires at least 262144" >&2; exit 1; }
echo "OK: static prerequisites. Runtime/functionality still require real startup checks."
