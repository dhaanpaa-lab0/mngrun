#!/usr/bin/env bash
docker compose -f compose.ferretdb.yml up -d
docker compose -f compose.ferretdb.yml exec mngrun /bin/bash
