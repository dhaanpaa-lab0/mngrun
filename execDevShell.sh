#!/usr/bin/env bash
docker build -t mngrun:latest .
docker run --rm -it \
    -e MONGO_URI="mongodb://localhost:27017/dd" \
    mngrun:latest \
    /bin/bash