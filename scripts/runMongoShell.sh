#!/usr/bin/env bash
echo "-------------------------------------------------------------------"
echo "                   MONGO SHELL QUERY FACILITY                      "
echo "==================================================================="

## Check for required environment variables
if [ -z "$MONGO_URI" ]; then
    echo "No 'MONGO_URI' specified"
    exit 1
fi

## Check for external script
if [ -z "$EXTERNAL_SCRIPT" ]; then
    echo "No 'EXTERNAL_SCRIPT' specified"
    exit 1
else
    echo "Using external script '$EXTERNAL_SCRIPT'"
    SCRIPT_FILE="/tmp/$(basename "$EXTERNAL_SCRIPT")"
    curl -fsSL "$EXTERNAL_SCRIPT" -o "$SCRIPT_FILE"
    if [ $? -ne 0 ]; then
        echo "Failed to download external script"
        exit 1
    fi
    echo "Downloaded external script to '$SCRIPT_FILE'"
    mongosh "$MONGO_URI" "$SCRIPT_FILE"
fi
exit 0