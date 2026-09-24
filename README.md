# JFStack — Wazuh 4.14.7 Docker Compose

Hardened single-node Wazuh deployment pinned to **4.14.7**.

## What is hardened

- Indexer `9200` is not published to the host.
- Manager API `55000` is not published to the host.
- Dashboard binds to `127.0.0.1:443` by default.
- Manager and Indexer use separate Docker networks.
- TLS/config bind mounts are read-only where compatible.
- `.env`, generated PKI, logs and backups stay outside Git.
- `json-file` logging is bounded.
- No Docker socket, host networking or `privileged`.

No arbitrary UID/GID, blanket `read_only`, capability drop or resource limits
are forced without image-specific runtime validation.

## First deployment

```bash
echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/99-wazuh.conf
sudo sysctl --system

make init
make pull
make certs
make check
make up
sleep 60
make status
make verify
```

`make init` creates `.env` only when missing and sets it to `0600`. It fetches
the exact upstream `v4.14.7` configuration files only when missing.

The fetched YAML/CONF files are set to `0644` deliberately. During real
validation, host-owned `0600` files caused `Permission denied` inside the
non-root Indexer/Dashboard processes. This is a documented compatibility
exception; the project does not hard-code undocumented container UID/GID
values.

## Passwords

`.env.example` contains Wazuh's known bootstrap credentials so a clean
installation matches the upstream hashes/settings.

Do **not** expose Dashboard externally with those bootstrap credentials.

After the first successful startup, rotate:

- Indexer `admin`;
- Indexer `kibanaserver`;
- Wazuh API `wazuh-wui`.

See [`docs/PASSWORDS.md`](docs/PASSWORDS.md).

The real local `.env` then contains your operational passwords and remains
ignored by Git.

Changing `.env` alone does not rotate Wazuh credentials.

For `wazuh-wui`, after changing the manager RBAC password and local `.env`:

```bash
make sync-api-password
docker compose up -d --force-recreate wazuh.dashboard
make verify
```

This synchronizes `config/wazuh_dashboard/wazuh.yml` and keeps `run_as: true`.

For `admin` and `kibanaserver`, follow the full Wazuh Docker password-change
procedure described in `docs/PASSWORDS.md`.

## TLS

```bash
make certs
```

Uses:

```text
wazuh/wazuh-certs-generator:0.0.4
CERT_TOOL_VERSION=4.14
```

Generated material lives under `config/wazuh_indexer_ssl_certs/` and is
ignored by Git. A complete PKI is preserved; a partial PKI makes generation
stop instead of mixing certificate sets.

## Ports

Published by default:

- TCP `1514`: agent communication;
- TCP `1515`: enrollment;
- UDP `514`: syslog;
- `127.0.0.1:443` → Dashboard `5601`.

Not host-published:

- Indexer `9200`;
- manager API `55000`.

Restrict 1514/1515/514 with bind IPs and host/network firewall rules.

## Traefik

`examples/compose.traefik.override.yml` contains an optional external Traefik
network example.

Dashboard exposure is enabled in the example. Indexer exposure is commented
out because attaching the Indexer to a shared proxy network increases lateral
reachability.

The external Traefik network must already exist.

## Agent

`agent/` contains an independent Wazuh Agent 4.14.7 deployment.

Wazuh 4.x uses TCP `1514` for agent communication and TCP `1515` for
enrollment.

This project does not force any agent group such as `Debian`. If an endpoint
requests a group, that group must exist in the manager or the endpoint
configuration must be corrected.

## Validation

```bash
make validate
make check
make up
make status
make verify
```

`make verify` looks for recent authentication and permission failures. It is a
smoke check, not a security certification.

## Persistence

`make down` preserves named volumes.

No automatic destructive `down -v`, backup, restore or upgrade target is
provided.

## Git safety

Before every commit:

```bash
git status --short
git ls-files | grep -E '(^|/)\.env$|\.key$|config/wazuh_indexer_ssl_certs/.*\.pem$' || true
```

## Upstream

Configuration source is pinned to the immutable Wazuh Docker tag `v4.14.7`.
