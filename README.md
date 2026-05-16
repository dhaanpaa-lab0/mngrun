# mngrun

A Docker-based MongoDB shell runner. Packages `mongosh` inside a container and runs queries against any MongoDB instance — either interactively or by downloading and executing an external script URL.

## Requirements

- Docker (with Compose for the stack-based workflow)

## Quick start

```bash
# Build the image
./build.sh

# Run mongosh interactively against localhost MongoDB
./execDev.sh

# Drop into a bash shell inside the container (for debugging)
./execDevShell.sh

# Start the full compose stack (mngrun + MongoDB sidecar) and shell in
./execComposeShell.sh
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
| `EXTERNAL_SCRIPT` | No | URL to a `.js` mongosh script — downloaded and executed at runtime |

## Cleanup

```bash
# Tear down the compose stack and remove all images and volumes
./purgeMongoRun.sh
```

## What's inside the image

Built on Ubuntu Noble, the image installs:

- `mongosh` 8.0 (MongoDB apt repo)
- Node.js LTS (NodeSource)
- AWS CLI v2 (official installer, amd64/arm64 aware)
