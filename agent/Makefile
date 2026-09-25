# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================

SHELL := /bin/sh
.DEFAULT_GOAL := help

.PHONY: help init install check status logs

help:
	@printf '%s\n' \
	  'JFStack Wazuh Agent 4.14.7 - Debian/Ubuntu' '' \
	  '  make init       Create local .env; do not overwrite existing config' \
	  '  sudo make install  Install/enroll agent using hostname as agent name' \
	  '  make check      Show package/service/enrollment status' \
	  '  make status     Show systemd status' \
	  '  make logs       Follow Wazuh agent log'

init:
	@./scripts/init.sh

install:
	@./scripts/install.sh

check:
	@./scripts/check.sh

status:
	@systemctl status wazuh-agent --no-pager

logs:
	@tail -F /var/ossec/logs/ossec.log
