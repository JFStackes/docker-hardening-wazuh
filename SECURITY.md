# Security

Do not report real passwords, private keys, enrollment credentials or other
secrets in public issues.

The initial Wazuh v4.14.7 bootstrap credentials are known upstream defaults
and must be rotated before external exposure. The Dashboard is therefore
loopback-bound by default.

Do not expose indexer 9200 or manager API 55000 unless there is a documented
requirement and compensating access control.

Generated certificates and `.env` files are excluded from Git. If a real
secret was committed or published, treat it as exposed and rotate it; adding
it to `.gitignore` does not remove repository history.
