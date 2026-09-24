#!/bin/sh
set -eu
# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================
compose_only=0
[ "${1:-}" = "--compose-only" ] && compose_only=1
fail(){ echo "ERROR: $*" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || fail "docker not found"
docker compose version >/dev/null 2>&1 || fail "docker compose unavailable"
[ -f .env ] || fail ".env missing; run make init"
mode=$(stat -c '%a' .env 2>/dev/null || true)
[ "$mode" = "600" ] || fail ".env must be mode 0600 (current: ${mode:-unknown})"
for f in \
  config/wazuh_cluster/wazuh_manager.conf \
  config/wazuh_indexer/wazuh.indexer.yml \
  config/wazuh_indexer/internal_users.yml \
  config/wazuh_dashboard/opensearch_dashboards.yml \
  config/wazuh_dashboard/wazuh.yml
do
  [ -s "$f" ] || fail "missing upstream config $f; run make init"
done
docker compose -f compose.yaml config --quiet
echo "OK: docker compose config --quiet"
[ "$compose_only" -eq 1 ] && exit 0
dir=config/wazuh_indexer_ssl_certs
bad=0
for f in root-ca.pem root-ca-manager.pem wazuh.manager.pem wazuh.manager-key.pem \
         wazuh.indexer.pem wazuh.indexer-key.pem admin.pem admin-key.pem \
         wazuh.dashboard.pem wazuh.dashboard-key.pem
do
  [ -f "$dir/$f" ] || { echo "MISSING: $dir/$f"; bad=1; }
done
[ "$bad" -eq 0 ] || fail "TLS files missing; run make certs"
vm=$(cat /proc/sys/vm/max_map_count 2>/dev/null || echo 0)
[ "$vm" -ge 262144 ] || fail "vm.max_map_count=$vm; Wazuh requires at least 262144"
echo "OK: static prerequisites."
echo "Runtime/functionality still require make verify after startup."
