# JFStack — Wazuh 4.14.7 Docker Compose

Hardened single-node Wazuh deployment based on the official Wazuh Docker
**v4.14.7** release. Wazuh publishes v4.14.7 as a release and its official
single-node Compose uses `wazuh-manager`, `wazuh-indexer` and
`wazuh-dashboard` 4.14.7.

## Design

The base Compose keeps the indexer private, does not publish the Wazuh API
55000 to the host, publishes the Dashboard only on `127.0.0.1` by default,
uses separate manager/indexer networks, read-only certificate/config bind
mounts and bounded JSON logs.

No blanket `read_only`, UID/GID override, capability drop or
`no-new-privileges` is forced because this repository has not runtime-tested
those restrictions against every Wazuh 4.14.7 container path.

## First deployment

Requirements: Docker Engine with Compose v2, `curl`, Internet access for the
first configuration fetch/image pull, and `vm.max_map_count >= 262144`.

```bash
sudo sysctl -w vm.max_map_count=262144
make init
make pull
make certs
make check
make up
make status
```

`make init` never overwrites `.env`. It fetches the five application
configuration files from the immutable upstream tag `v4.14.7` only when they
are missing. This avoids silently tracking `main`.

`make certs` uses the official `wazuh/wazuh-certs-generator:0.0.4` image with
`CERT_TOOL_VERSION=4.14`, matching Wazuh's documented 4.14 certificate flow.

## Bootstrap credentials — mandatory rotation

The v4.14.7 upstream `internal_users.yml` and dashboard configuration contain
known bootstrap credentials. `.env.example` deliberately matches those values
so the official configuration can boot consistently.

**Do not expose the Dashboard through Traefik or the Internet with bootstrap
credentials.** The base configuration binds it to `127.0.0.1`.

After the first successful startup, rotate the `admin`, `kibanaserver` and
Wazuh API credentials using Wazuh's official Docker password-change procedure,
then update `.env` and the corresponding Wazuh configuration/keystores as
documented by Wazuh. Changing `.env` alone does not change the password hashes
inside the indexer.

## Ports

- `1514/TCP`: agent communication.
- `1515/TCP`: agent enrollment.
- `514/UDP`: optional syslog listener retained from upstream.
- Dashboard `5601` is mapped to host `${WAZUH_DASHBOARD_PORT:-443}` on
  `127.0.0.1` by default.
- Indexer `9200` and manager API `55000` are not host-published.

Restrict the bind IPs/firewall for 1514, 1515 and 514 to the networks that
actually require them.

## TLS

The generated PKI lives under `config/wazuh_indexer_ssl_certs/` and is ignored
by Git. Generation is non-destructive: a complete PKI is kept; a partial PKI
causes `make certs` to stop instead of mixing certificate sets.

## Traefik

`examples/compose.traefik.override.yml` shows an optional external Traefik
network. The Dashboard block is enabled; the indexer block is commented
because putting the indexer on a shared proxy network increases lateral
reachability.

The Traefik network is external and must be created/managed outside this
project. TLS verification between Traefik and the HTTPS backend also needs to
be configured in Traefik; this project does not disable backend verification
automatically.

Example validation:

```bash
docker compose -f compose.yaml \
  -f examples/compose.traefik.override.yml config
```

## Agent

`agent/` is a standalone Docker deployment using
`wazuh/wazuh-agent:4.14.7`. It uses the Wazuh 4.x manager/enrollment model
(1514/1515), not the 5.x unified HTTPS endpoint.

## Validation levels

`make validate` checks Compose expansion and required vendored configuration.
`make check` additionally checks TLS files and `vm.max_map_count`.
`make up` performs those checks and starts containers.

These are not proof of runtime functionality or security. After startup,
inspect `make status`, `make logs`, Dashboard access, indexer health and a real
agent enrollment.

## Persistence and destructive operations

`make down` does not remove named volumes. No automatic destructive
`down -v`, backup, restore or upgrade target is provided. Define and test a
Wazuh-aware backup/restore procedure before relying on this deployment for
important data.

## Git safety

Never commit `.env`, generated TLS material, backups or logs:

```bash
git status --short
git ls-files | grep -E '(^|/)\.env$|\.key$|config/wazuh_indexer_ssl_certs/.*\.pem$' || true
```

## Upstream

Configuration source is pinned to:
`https://github.com/wazuh/wazuh-docker/tree/v4.14.7/single-node`

Wazuh remains subject to its upstream licenses and notices. JFStack changes
are deployment/hardening glue around the upstream project.
