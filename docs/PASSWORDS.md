# Rotación de contraseñas — Wazuh 4.14.7

El `.env` real contiene las contraseñas operativas y debe permanecer local,
con modo `0600` y fuera de Git.

Cambiar únicamente `.env` **no rota** las credenciales internas de Wazuh.

Referencia oficial:
https://documentation.wazuh.com/current/deployment-options/docker/changing-default-password.html

## `admin` — Manager/Filebeat → Indexer

1. Cierra la sesión del Dashboard.
2. Define la nueva contraseña en `.env`.
3. Genera el hash usando la imagen 4.14.7:

```bash
docker run --rm -it \
  wazuh/wazuh-indexer:4.14.7 \
  bash /usr/share/wazuh-indexer/plugins/opensearch-security/tools/hash.sh
```

4. Sustituye solo `admin.hash` en
   `config/wazuh_indexer/internal_users.yml`.
5. Aplica la configuración de seguridad del Indexer siguiendo el procedimiento
   oficial y valida que el usuario devuelve HTTP 200.
6. Recrea el manager y revisa que no aparecen `401 Unauthorized`.

El usuario `admin` lo utiliza Filebeat/manager para hablar con el Indexer.

## `kibanaserver` — Dashboard → Indexer

1. Genera el nuevo hash con el mismo comando `hash.sh`.
2. Sustituye solo `kibanaserver.hash` en
   `config/wazuh_indexer/internal_users.yml`.
3. Aplica la configuración de seguridad del Indexer.
4. Actualiza `WAZUH_DASHBOARD_INDEXER_PASSWORD` en `.env`.
5. Actualiza el keystore del Dashboard:

```bash
KIBANA_PASS="$(sed -n 's/^WAZUH_DASHBOARD_INDEXER_PASSWORD=//p' .env)"

printf '%s' "$KIBANA_PASS" | \
docker compose exec -T wazuh.dashboard \
  /usr/share/wazuh-dashboard/bin/opensearch-dashboards-keystore \
  --allow-root add -f --stdin opensearch.password
```

6. Recrea Dashboard y verifica que deja de devolver `ResponseError`/401.

## `wazuh-wui` — Dashboard → Wazuh API

En Wazuh 4.14.7 el mecanismo que se validó en ejecución es interactivo:

```bash
docker compose exec wazuh.manager \
  /var/ossec/bin/rbac_control change-password
```

Pulsa Enter para omitir `wazuh` y establece en `wazuh-wui` exactamente la
contraseña que guardarás en:

```text
WAZUH_API_PASSWORD
```

Después:

```bash
make sync-api-password
docker compose up -d --force-recreate wazuh.dashboard
make verify
```

`make sync-api-password` actualiza `config/wazuh_dashboard/wazuh.yml` sin
imprimir la contraseña y conserva `run_as: true`.

## Comprobaciones sin mostrar secretos

Comparar el password de `.env` y el recibido por el manager:

```bash
printf '%s' "$(sed -n 's/^WAZUH_INDEXER_ADMIN_PASSWORD=//p' .env)" | sha256sum
docker compose exec -T wazuh.manager sh -c \
  'printf "%s" "$INDEXER_PASSWORD" | sha256sum'
```

Comprobar autenticación de `wazuh-wui`:

```bash
WUI_PASS="$(sed -n 's/^WAZUH_API_PASSWORD=//p' .env)"

docker compose exec -T -e WUI_PASS="$WUI_PASS" wazuh.manager bash -lc '
  R=$(curl -sk -u "wazuh-wui:$WUI_PASS" \
    -X POST "https://localhost:55000/security/user/authenticate?raw=true")
  case "$R" in
    *Unauthorized*) echo "ERROR: authentication failed"; exit 1 ;;
    *) echo "OK: wazuh-wui authentication works" ;;
  esac
'
```

## Git

Antes de cada commit:

```bash
git status --short
git ls-files | grep -E '(^|/)\.env$|\.key$|config/wazuh_indexer_ssl_certs/.*\.pem$' || true
```

Si una credencial real ha sido publicada, hay que rotarla. `.gitignore` no la
elimina del historial.
