# mngrun

A Docker-based MongoDB shell runner. Packages `mongosh` inside a container and runs queries against any MongoDB instance — either interactively or by downloading and executing an external script URL.

## Requirements

- Docker (with Compose for the stack-based workflow)

## Quick start

```bash
# Build the image
./build.sh

# Build and run against localhost MongoDB (requires EXTERNAL_SCRIPT or GIT_SCRIPT_REPO)
./execDev.sh

# Build and drop into a bash shell inside the container (for debugging)
./execDevShell.sh

# Start the MongoDB compose stack and shell into the mngrun container
./execComposeShell.sh

# Start the FerretDB compose stack and shell into the mngrun container
./execFerretComposeShell.sh
```

`execDev.sh` and `execDevShell.sh` connect to `mongodb://localhost:27017/dd` by default.

## Running with an external script

```bash
docker run --rm -it \
    -e MONGO_URI="mongodb://host:27017/mydb" \
    -e EXTERNAL_SCRIPT="https://example.com/query.js" \
    mngrun:latest
```

The entrypoint downloads the script to `/tmp/` at runtime and passes it to `mongosh`.

## Environment variables

| Variable | Required | Description |
|---|---|---|
| `MONGO_URI` | Yes | MongoDB connection string |
| `EXTERNAL_SCRIPT` | No | URL to a `.js` mongosh script — downloaded to `/tmp/` at runtime and executed |
| `GIT_SCRIPT_REPO` | No | Git repo URL cloned to `/work/local-scripts/` at runtime; scripts inside can then be referenced as `$1` |

A script must be provided via `EXTERNAL_SCRIPT`, `GIT_SCRIPT_REPO` (with a script path passed as the first argument), or a direct path argument — the entrypoint exits with an error if no script is found.

## FerretDB stack

`compose.ferretdb.yml` runs FerretDB (backed by Postgres) as a MongoDB-compatible sidecar:

```bash
# Start the FerretDB stack and shell into the mngrun container
./execFerretComposeShell.sh

# Tear down the FerretDB stack and remove all images and volumes
./purgeFerretRun.sh
```

See [FERRETDB_SETUP.md](FERRETDB_SETUP.md) for instructions on enabling authentication and creating the initial admin user.

## Cleanup

```bash
# Tear down the MongoDB compose stack and remove all images and volumes
./purgeMongoRun.sh

# Tear down the FerretDB compose stack and remove all images and volumes
./purgeFerretRun.sh
```

## What's inside the image

Built on Ubuntu Noble, the image installs:

- `mongosh` 8.0 (MongoDB apt repo)
- Node.js LTS (NodeSource)
- AWS CLI v2 (official installer, amd64/arm64 aware)

## Additional Notes

Designed to run with Joy and Happiness.

Designed to work with very little ceremony.

