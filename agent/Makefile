SHELL := /bin/sh
.DEFAULT_GOAL := help
.PHONY: help init validate up down status logs
help:
	@printf '%s\n' 'Wazuh Agent 4.14.7' '  make init | validate | up | down | status | logs'
init:
	@[ -f .env ] || { cp .env.example .env; chmod 600 .env; echo "Created agent/.env"; }
validate:
	@docker compose -f compose.yaml config --quiet
up:
	@docker compose -f compose.yaml config --quiet
	@docker compose -f compose.yaml up -d
down:
	@docker compose -f compose.yaml down
status:
	@docker compose -f compose.yaml ps
logs:
	@docker compose -f compose.yaml logs -f --tail=100
