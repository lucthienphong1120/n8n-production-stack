#!/bin/bash

echo "Start restore workflow"
docker exec -it n8n n8n import:workflow --input backup/workflow.json

echo "Start restore credentials"
docker exec -it n8n n8n import:credentials --input backup/credentials.json
