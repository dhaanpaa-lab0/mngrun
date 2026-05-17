# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project does

**mngrun** is a Docker-based MongoDB shell runner. It packages `mongosh` inside a container and can run queries against any MongoDB instance — either interactively or by downloading and executing an external script URL.

## Commands

```bash
# Build the image only
./build.sh

# Build image and run against localhost MongoDB (requires a script via EXTERNAL_SCRIPT, GIT_SCRIPT_REPO, or $1)
./execDev.sh

# Build image and drop into a bash shell inside the container (against localhost MongoDB)
./execDevShell.sh

# Start the MongoDB compose stack (mngrun + MongoDB) and shell into the mngrun container
./execComposeShell.sh

# Start the FerretDB compose stack (mngrun + FerretDB + Postgres) and shell into the mngrun container
./execFerretComposeShell.sh
```

`execDev.sh` and `execDevShell.sh` build `mngrun:latest` and connect to `mongodb://localhost:27017/dd`. `execComposeShell.sh` uses `compose.yml` where MongoDB runs as a sidecar. `execFerretComposeShell.sh` uses `compose.ferretdb.yml` where FerretDB (backed by Postgres 16) is the sidecar.

## Environment variables (passed to `docker run`)

| Variable | Required | Description |
|---|---|---|
| `MONGO_URI` | Yes | MongoDB connection string |
| `EXTERNAL_SCRIPT` | No | URL to a `.js` mongosh script — downloaded to `/tmp/` at runtime and executed |
| `GIT_SCRIPT_REPO` | No | Git repo URL cloned to `/work/local-scripts/` at runtime (installs `git-core` via apt on first run) |

A script must be provided via `EXTERNAL_SCRIPT`, a path argument `$1`, or by cloning `GIT_SCRIPT_REPO` and passing a script path. Without one, the entrypoint exits with an error.

Example with an external script:
```bash
docker run --rm -it \
    -e MONGO_URI="mongodb://host:27017/mydb" \
    -e EXTERNAL_SCRIPT="https://example.com/query.js" \
    mngrun:latest
```

## Architecture

- **Dockerfile** — Ubuntu Noble base, installs `mongosh` 8.0 (MongoDB apt repo), Node.js LTS (NodeSource), and AWS CLI v2 (official installer, amd64/arm64 aware), copies `scripts/runMongoShell.sh` as the entrypoint.
- **scripts/runMongoShell.sh** — Entrypoint. Validates `MONGO_URI`, optionally clones `GIT_SCRIPT_REPO` to `/work/local-scripts/`, optionally downloads `EXTERNAL_SCRIPT` via `curl` to `/tmp/`, then invokes `mongosh <URI> <script>`. Exits with an error if no script is resolved.
- **execDev.sh** — Convenience wrapper: build + run against `mongodb://localhost:27017/dd`.
- **execDevShell.sh** — Same as above but overrides CMD with `/bin/bash` for debugging inside the container.
- **compose.yml** — Compose stack with `mongodb` (mongo:8.0) and `mngrun` (built locally). Sets `GIT_SCRIPT_REPO` and overrides CMD to `sleep infinity` so the container stays alive for `exec`.
- **compose.ferretdb.yml** — Compose stack with `postgres:16`, `ferretdb` (MongoDB-compatible, backed by Postgres), and `mngrun`. Exposes FerretDB on port 27017.
- **execComposeShell.sh** — Starts the MongoDB compose stack detached, then execs into the mngrun container via bash.
- **execFerretComposeShell.sh** — Starts the FerretDB compose stack detached, then execs into the mngrun container via bash.
- **purgeMongoRun.sh** — Tears down the MongoDB compose stack (`compose.yml`) removing images and volumes.
- **purgeFerretRun.sh** — Tears down the FerretDB compose stack (`compose.ferretdb.yml`) removing images and volumes.

## Notes

- `compose.yml` sets `GIT_SCRIPT_REPO` to `https://github.com/dhaanpaa-lab0/mngrun` as a default script source for the compose workflow.
- The FerretDB stack (`compose.ferretdb.yml`) is useful for testing MongoDB-compatible queries without a real MongoDB instance; FerretDB translates mongosh wire protocol to Postgres SQL.
