# Password rotation — Wazuh 4.14.7

The runtime `.env` contains local operational passwords. It is mode `0600`,
ignored by Git, and must not be published.

Changing `.env` alone does **not** rotate Wazuh credentials.

## `admin`

Used by the manager/Filebeat to communicate with the Indexer and as an Indexer
administrator account.

A correct rotation requires the complete Wazuh Docker procedure:

1. choose the new value;
2. generate a new password hash with the Indexer `hash.sh`;
3. replace `admin.hash` in `config/wazuh_indexer/internal_users.yml`;
4. apply the security configuration with `securityadmin.sh`;
5. update the manager/Filebeat credential;
6. restart affected services and verify logs.

## `kibanaserver`

Used by Dashboard to communicate with the Indexer.

A correct rotation requires:

1. update the password/hash in `internal_users.yml`;
2. apply the Indexer security configuration;
3. update `WAZUH_DASHBOARD_INDEXER_PASSWORD` in `.env`;
4. update the Dashboard OpenSearch keystore;
5. recreate/restart Dashboard.

## `wazuh-wui`

Used by Dashboard to communicate with the Wazuh API.

Wazuh 4.14.7 exposes the local interactive RBAC tool:

```bash
docker compose exec wazuh.manager \
  /var/ossec/bin/rbac_control change-password
```

Press Enter to skip users you do not want to change. When changing
`wazuh-wui`, put the same password in local `.env`, then run:

```bash
make sync-api-password
docker compose up -d --force-recreate wazuh.dashboard
make verify
```

`make sync-api-password` updates the mounted `wazuh.yml` without printing the
secret and restores `run_as: true`.

Wazuh API passwords must be 8–64 characters and contain uppercase, lowercase,
a number and a symbol.

## Git safety

```bash
git status --short
git ls-files | grep -E '(^|/)\.env$|\.key$|config/wazuh_indexer_ssl_certs/.*\.pem$' || true
```

If a real credential was published, rotate it. `.gitignore` cannot remove it
from Git history.
