#!/usr/bin/env bash
echo "-------------------------------------------------------------------"
echo "                   MONGO SHELL QUERY FACILITY                      "
echo "==================================================================="

## Check for required environment variables
if [ -z "$MONGO_URI" ]; then
    echo "No 'MONGO_URI' specified"
    exit 1
fi

## Setup Local Repo for scripts to make available
if [ ! -z "$GIT_SCRIPT_REPO" ]; then
    mkdir -pv /work/local-scripts
    cd /work/local-scripts
    apt update
    apt install -y git-core
    git clone "$GIT_SCRIPT_REPO" /work/local-scripts
fi

## Check for external script
if [ ! -z "$EXTERNAL_SCRIPT" ]; then    
    echo "Using external script '$EXTERNAL_SCRIPT'"
    SCRIPT_FILE="/tmp/$(basename "$EXTERNAL_SCRIPT")"
    curl -fsSL "$EXTERNAL_SCRIPT" -o "$SCRIPT_FILE"
    if [ $? -ne 0 ]; then
        echo "Failed to download external script"
        exit 1
    fi
    echo "Downloaded external script to '$SCRIPT_FILE'"
else
    SCRIPT_FILE="$1"
fi


if [ -z "$SCRIPT_FILE" ]; then
    echo "Script file not found"
    exit 1
else 
    mongosh "$MONGO_URI" "$SCRIPT_FILE"
    exit 0
fi