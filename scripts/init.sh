#!/bin/sh
set -eu
# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================
umask 077
if [ ! -f .env ]; then
  cp .env.example .env
  chmod 0600 .env
  echo "Created .env with Wazuh 4.14.7 bootstrap credentials."
  echo "Do not expose the Dashboard externally before rotating them."
else
  chmod 0600 .env
  echo ".env already exists; it was not modified."
fi
mkdir -p config/wazuh_indexer_ssl_certs
./scripts/fetch-upstream-config.sh
echo "Initialization complete."
echo "Next: make pull && make certs && make check && make up"
