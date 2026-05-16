# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project does

**mngrun** is a Docker-based MongoDB shell runner. It packages `mongosh` inside a container and can run queries against any MongoDB instance — either interactively or by downloading and executing an external script URL.

## Commands

```bash
# Build the image only
./build.sh

# Build image and run mongosh interactively (against localhost MongoDB)
./execDev.sh

# Build image and drop into a bash shell inside the container (against localhost MongoDB)
./execDevShell.sh

# Start the full compose stack (mngrun + MongoDB) and shell into the mngrun container
./execComposeShell.sh
```

`execDev.sh` and `execDevShell.sh` build `mngrun:latest` and connect to `mongodb://localhost:27017/dd`. `execComposeShell.sh` uses the compose stack where MongoDB runs as a sidecar service.

## Environment variables (passed to `docker run`)

| Variable | Required | Description |
|---|---|---|
| `MONGO_URI` | Yes | MongoDB connection string |
| `EXTERNAL_SCRIPT` | No | URL to a `.js` mongosh script — downloaded at runtime and executed |

Example with an external script:
```bash
docker run --rm -it \
    -e MONGO_URI="mongodb://host:27017/mydb" \
    -e EXTERNAL_SCRIPT="https://example.com/query.js" \
    mngrun:latest
```

## Architecture

- **Dockerfile** — Ubuntu Noble base, installs `mongosh` 8.0 (MongoDB apt repo), Node.js LTS (NodeSource), and AWS CLI v2 (official installer, amd64/arm64 aware), copies `scripts/runMongoShell.sh` as the entrypoint.
- **scripts/runMongoShell.sh** — Entrypoint. Validates `MONGO_URI`, optionally downloads `EXTERNAL_SCRIPT` via `curl` to `/tmp/`, then invokes `mongosh <URI> [script]`.
- **execDev.sh** — Convenience wrapper: build + run with the default CMD (mongosh interactive).
- **execDevShell.sh** — Same as above but overrides CMD with `/bin/bash` for debugging inside the container.
- **compose.yml** — Compose stack with `mongodb` (mongo:8.0) and `mngrun` (built locally). The mngrun service overrides CMD to `sleep infinity` so it stays alive for `exec`.
- **execComposeShell.sh** — Starts the compose stack detached, then execs into the mngrun container via bash.

## Notes

- `runMongoShell.sh` has an incomplete guard comment (`## Che`) before the final `mongosh` call — this appears to be a stub left in progress.
