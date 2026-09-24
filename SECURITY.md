# Security

Never publish real `.env` files, private keys, enrollment credentials,
backups or sensitive logs.

The bootstrap credentials in `.env.example` are public defaults and must be
rotated before external exposure. Dashboard is loopback-bound by default.

Keep `.env` mode `0600`. Restrict 1514/1515/514 to the networks that need
them. Keep Indexer 9200 and API 55000 internal unless explicitly required.

If a real credential is committed, treat it as exposed and rotate it.
