#!/bin/sh
set -eu
# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================
dir=config/wazuh_indexer_ssl_certs
required='
root-ca.pem
root-ca-manager.pem
wazuh.manager.pem
wazuh.manager-key.pem
wazuh.indexer.pem
wazuh.indexer-key.pem
admin.pem
admin-key.pem
wazuh.dashboard.pem
wazuh.dashboard-key.pem
'
all=1
partial=0
for f in $required; do
    [ -f "$dir/$f" ] || all=0
    [ -e "$dir/$f" ] && partial=1
done
if [ "$all" -eq 1 ]; then
    echo "TLS material already exists; certificates were not regenerated."
    ./scripts/fix-cert-permissions.sh
    exit 0
fi
[ "$partial" -eq 0 ] || { echo "ERROR: partial TLS material exists in $dir; refusing to mix PKI material." >&2; exit 1; }

docker compose -f generate-indexer-certs.yml run --rm generator

for f in $required; do
    [ -f "$dir/$f" ] || { echo "ERROR: generator did not create $dir/$f" >&2; exit 1; }
done

./scripts/fix-cert-permissions.sh
echo "OK: Wazuh TLS material generated."
