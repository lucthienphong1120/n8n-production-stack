#!/bin/bash

LOG_FILE="/var/log/n8n-backup.log"
exec > >(while IFS= read -r line; do echo "$(date '+%Y-%m-%d %H:%M:%S') $line"; done >> "$LOG_FILE") 2>&1

echo "Start backup workflow"
docker exec n8n n8n export:workflow --all --output backup/workflow.json

echo "Start backup credentials"
docker exec n8n n8n export:credentials --all --output backup/credentials.json

echo "Done"
