#!/bin/sh
set -eu
# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================
CERT_DIR="${CERT_DIR:-config/wazuh_indexer_ssl_certs}"
IMAGE="${WAZUH_INDEXER_IMAGE:-wazuh/wazuh-indexer:4.14.7}"

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
for f in $required; do
    [ -f "$CERT_DIR/$f" ] || { echo "ERROR: missing $CERT_DIR/$f" >&2; exit 1; }
done

docker run --rm \
    --user 0:0 \
    --entrypoint /bin/sh \
    -v "$PWD/$CERT_DIR:/certs" \
    "$IMAGE" \
    -c '
        set -eu
        chown 1000:1000 \
          /certs/root-ca.pem \
          /certs/wazuh.indexer.pem \
          /certs/wazuh.indexer-key.pem \
          /certs/admin.pem \
          /certs/admin-key.pem \
          /certs/wazuh.dashboard.pem \
          /certs/wazuh.dashboard-key.pem

        chmod 0444 \
          /certs/root-ca.pem \
          /certs/wazuh.indexer.pem \
          /certs/admin.pem \
          /certs/wazuh.dashboard.pem

        chmod 0400 \
          /certs/wazuh.indexer-key.pem \
          /certs/admin-key.pem \
          /certs/wazuh.dashboard-key.pem

        chmod 0444 /certs/root-ca-manager.pem /certs/wazuh.manager.pem
        chmod 0400 /certs/wazuh.manager-key.pem
        [ ! -e /certs/root-ca.key ] || chmod 0400 /certs/root-ca.key
        [ ! -e /certs/root-ca-manager.key ] || chmod 0400 /certs/root-ca-manager.key
    '

echo "OK: TLS ownership/permissions adjusted for Wazuh 4.14.7."
