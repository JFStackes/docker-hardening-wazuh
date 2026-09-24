# Wazuh Agent 4.14.7 (Docker)

Standalone agent deployment matching the manager version.

```bash
make init
nano .env
make validate
make up
make status
```

Wazuh 4.x uses TCP/1514 for agent communication and TCP/1515 for automatic
enrollment. The manager must be reachable on those ports.

`/var/ossec/etc` is persisted so the enrollment identity survives container
recreation. `docker compose down` preserves that volume.

The registration password is optional when the manager enrollment service is
configured without password authentication. Do not commit `agent/.env`.

This container is intentionally not given Docker socket access, host PID,
privileged mode, devices, or broad host mounts. Add host visibility only for a
specific monitoring requirement and document the resulting privilege.
