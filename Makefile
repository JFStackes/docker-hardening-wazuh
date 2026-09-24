# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================
SHELL := /bin/sh
.DEFAULT_GOAL := help
.PHONY: help init certs validate check up down status logs pull

help:
	@printf '%s\n' \
	  'JFStack Wazuh 4.14.7 single-node' '' \
	  '  make init      Create .env and fetch exact v4.14.7 upstream configs' \
	  '  make certs     Generate Wazuh self-signed certificates' \
	  '  make validate  Validate Compose/config presence' \
	  '  make check     Validate TLS and host prerequisites' \
	  '  make pull      Pull pinned container images' \
	  '  make up        Check then start' \
	  '  make down      Stop; preserve volumes' \
	  '  make status    Show status' \
	  '  make logs      Follow logs'

init:
	@./scripts/init.sh
certs:
	@./scripts/generate-certs.sh
validate:
	@./scripts/check.sh --compose-only
check:
	@./scripts/check.sh
pull:
	@docker compose -f compose.yaml pull
up:
	@./scripts/check.sh
	@docker compose -f compose.yaml up -d
down:
	@docker compose -f compose.yaml down
status:
	@docker compose -f compose.yaml ps
logs:
	@docker compose -f compose.yaml logs -f --tail=200
