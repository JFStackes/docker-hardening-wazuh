#!/bin/sh
set -eu
# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================
umask 077
[ -f .env ] || { cp .env.example .env; chmod 600 .env; echo "Created .env (bootstrap credentials; rotate before external exposure)."; }
[ -f .env ] && chmod 600 .env
mkdir -p config/wazuh_indexer_ssl_certs
./scripts/fetch-upstream-config.sh
echo "Initialization complete. Next: make certs"
