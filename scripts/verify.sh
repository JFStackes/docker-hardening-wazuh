#!/bin/sh
set -eu
# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================
docker compose -f compose.yaml ps
echo
echo "Checking recent authentication/startup errors..."
errors=$(docker compose -f compose.yaml logs --since=2m 2>/dev/null \
  | grep -E '401 Unauthorized|Authentication finally failed|Permission denied|AccessDeniedException|Invalid credentials' || true)
if [ -n "$errors" ]; then
  printf '%s\n' "$errors"
  echo "WARN: recent authentication/permission errors detected." >&2
  exit 1
fi
echo "OK: no recent authentication/permission errors matched."
echo "This is a functional smoke check, not a security certification."
