#!/bin/sh
set -eu
# =============================================================================
# JFStack
# Web: https://jfstack.es
# GitHub: https://github.com/JFStackes
# =============================================================================
[ -f .env ] || { echo "ERROR: .env not found" >&2; exit 1; }
[ -f config/wazuh_dashboard/wazuh.yml ] || { echo "ERROR: wazuh.yml not found; run make init" >&2; exit 1; }
python3 - <<'PY'
from pathlib import Path
import re
password = None
for line in Path(".env").read_text().splitlines():
    if line.startswith("WAZUH_API_PASSWORD="):
        password = line.split("=", 1)[1]
        break
if not password:
    raise SystemExit("ERROR: WAZUH_API_PASSWORD missing or empty in .env")
path = Path("config/wazuh_dashboard/wazuh.yml")
text = path.read_text()
escaped = password.replace("\\", "\\\\").replace('"', '\\"')
new, count = re.subn(r'^(\s*password:\s*).*$', lambda m: m.group(1) + '"' + escaped + '"',
                     text, count=1, flags=re.MULTILINE)
if count != 1:
    raise SystemExit("ERROR: expected exactly one password field in wazuh.yml")
new = re.sub(r'^(\s*run_as:\s*).*$', lambda m: m.group(1) + 'true',
             new, count=1, flags=re.MULTILINE)
path.write_text(new)
PY
chmod 0644 config/wazuh_dashboard/wazuh.yml
echo "OK: wazuh.yml synchronized with WAZUH_API_PASSWORD; secret not printed."
