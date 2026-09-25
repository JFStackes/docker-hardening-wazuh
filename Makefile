# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================
SHELL := /bin/sh
.DEFAULT_GOAL := help
.PHONY: help init pull certs fix-permissions validate check up down status logs verify sync-api-password

help:
	@printf '%s\n' \
	  'JFStack Wazuh 4.14.7 single-node' '' \
	  '  make init               Create .env and fetch v4.14.7 configs' \
	  '  make pull               Pull pinned container images' \
	  '  make certs              Generate PKI and apply runtime-safe permissions' \
	  '  make fix-permissions    Reapply validated config/TLS permissions' \
	  '  make validate           Validate Compose/config presence' \
	  '  make check              Validate TLS and host prerequisites' \
	  '  make up                 Check then start the stack' \
	  '  make down               Stop; preserve volumes' \
	  '  make status             Show status' \
	  '  make logs               Follow logs' \
	  '  make verify             Smoke-check recent runtime errors' \
	  '  make sync-api-password  Sync .env WAZUH_API_PASSWORD into wazuh.yml'

init:
	@./scripts/init.sh

pull:
	@docker compose -f compose.yaml pull

certs:
	@./scripts/generate-certs.sh

fix-permissions:
	@chmod 0644 \
	  config/wazuh_cluster/wazuh_manager.conf \
	  config/wazuh_indexer/wazuh.indexer.yml \
	  config/wazuh_indexer/internal_users.yml \
	  config/wazuh_dashboard/opensearch_dashboards.yml \
	  config/wazuh_dashboard/wazuh.yml
	@chmod 0600 .env
	@./scripts/fix-cert-permissions.sh

validate:
	@./scripts/check.sh --compose-only

check:
	@./scripts/check.sh

up:
	@./scripts/check.sh
	@docker compose -f compose.yaml up -d

down:
	@docker compose -f compose.yaml down

status:
	@docker compose -f compose.yaml ps

logs:
	@docker compose -f compose.yaml logs -f --tail=200

verify:
	@./scripts/verify.sh

sync-api-password:
	@./scripts/sync-dashboard-api-password.sh
