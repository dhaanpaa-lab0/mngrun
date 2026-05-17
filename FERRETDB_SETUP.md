# FerretDB Setup

FerretDB is a MongoDB-compatible database backed by Postgres. By default the compose stack runs **without authentication**. This guide covers enabling auth and creating the initial admin user.

## Default (no auth)

The stack as shipped connects without credentials:

```bash
./execFerretComposeShell.sh
# inside the container:
mongosh mongodb://ferretdb:27017/dd
```

## Enabling authentication

### 1. Start the stack and create the initial admin user

Start without auth first so you can connect freely to create the user:

```bash
./execFerretComposeShell.sh
```

Inside the mngrun container:

```bash
mongosh mongodb://ferretdb:27017/
```

Inside mongosh:

```js
use admin
db.createUser({
  user: "admin",
  pwd:  "changeme",
  roles: [{ role: "root", db: "admin" }]
})
exit
```

### 2. Enable auth in the compose file

Add `FERRETDB_AUTH: "true"` to the `ferretdb` service in `compose.ferretdb.yml`:

```yaml
  ferretdb:
    image: ghcr.io/ferretdb/ferretdb
    environment:
      FERRETDB_POSTGRESQL_URL: postgresql://ferretdb:ferretdb@postgres:5432/ferretdb
      FERRETDB_AUTH: "true"
    ports:
      - "27017:27017"
    depends_on:
      - postgres
```

### 3. Update the mngrun MONGO_URI to include credentials

```yaml
  mngrun:
    build: .
    environment:
      MONGO_URI: mongodb://admin:changeme@ferretdb:27017/dd?authSource=admin
    command: sleep infinity
    depends_on:
      - ferretdb
```

### 4. Restart the stack

```bash
./purgeFerretRun.sh
./execFerretComposeShell.sh
```

The stack now requires credentials. Verify inside the container:

```bash
mongosh "mongodb://admin:changeme@ferretdb:27017/dd?authSource=admin"
```

## Creating additional users

Connect as admin, then create per-database users as needed:

```js
use dd
db.createUser({
  user: "appuser",
  pwd:  "apppassword",
  roles: [{ role: "readWrite", db: "dd" }]
})
```

## Notes

- `authSource=admin` is required in the connection string because FerretDB (like MongoDB) validates credentials against the database they were created in — admin users live in the `admin` db.
- The Postgres credentials (`POSTGRES_USER`, `POSTGRES_PASSWORD`) are separate from MongoDB-level credentials and are internal to the FerretDB ↔ Postgres connection.
- FerretDB v2 requires the DocumentDB Postgres extension. The compose stack uses `ghcr.io/ferretdb/postgres-documentdb:16` instead of plain `postgres:16` — do not swap this back or you will get a `schema "documentdb_api" does not exist` error.
- To reset all users, run `./purgeFerretRun.sh` (removes the `postgres_data` volume) and repeat this guide from step 1.
