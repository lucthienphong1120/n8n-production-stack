#!/bin/bash

LOG_FILE="/var/log/n8n-backup.log"
DATE=$(date +%Y%m%d)
BASE_BACKUP_DIR="/root/n8n/backup"
TARGET_DIR="$BASE_BACKUP_DIR/$DATE"
QDRANT_SNAP_HOST="/root/n8n/qdrant-snapshots"

# Logging (Stdout + log file)
exec > >(while IFS= read -r line; do echo "$(date '+%Y-%m-%d %H:%M:%S') $line"; done | tee -a "$LOG_FILE") 2>&1
echo "--- Bắt đầu Backup $DATE ---"
mkdir -p "$TARGET_DIR"

# Function: Chia nhỏ file nếu > 25MB
split_if_large() {
    local file=$1
    if [[ -f "$file" && -s "$file" ]]; then
        local size=$(stat -c%s "$file")
        if [ "$size" -gt 26214400 ]; then
            echo "File $(basename "$file") ($(du -h "$file" | cut -f1)) > 25MB, đang chia nhỏ..."
            split -b 25M "$file" "${file}.part" && rm "$file"
        fi
    else
        echo "Cảnh báo: $(basename "$file") trống hoặc không tồn tại. Bỏ qua split."
    fi
}

# 1. Backup Postgres Database
echo "Backing up Postgres..."
docker exec postgres pg_dump -U postgres n8n | gzip > "$TARGET_DIR/postgres.sql.gz"
split_if_large "$TARGET_DIR/postgres.sql.gz"

# 2. Backup n8n (Workflows & Credentials)
echo "Backup n8n workflow & credentials"
docker exec n8n n8n export:workflow --all --output backup/workflow.json
docker exec n8n n8n export:credentials --all --output backup/credentials.json
[ -f "$BASE_BACKUP_DIR/workflow.json" ] && mv "$BASE_BACKUP_DIR/workflow.json" "$TARGET_DIR/"
[ -f "$BASE_BACKUP_DIR/credentials.json" ] && mv "$BASE_BACKUP_DIR/credentials.json" "$TARGET_DIR/"
split_if_large "$TARGET_DIR/workflow.json"
split_if_large "$TARGET_DIR/credentials.json"

# 3. Snapshot qdrant
echo "Creating Qdrant snapshot..."
curl -s -X POST "http://localhost:6333/snapshots" > /dev/null
sleep 2
LATEST_SNAP=$(ls -t $QDRANT_SNAP_HOST/*.snapshot 2>/dev/null | head -1)
mv $LATEST_SNAP "$TARGET_DIR/qdrant.snapshot"
split_if_large "$TARGET_DIR/qdrant.snapshot"

# Dọn dẹp (Giữ tối đa 5 bản mới nhất)
echo "Cleaning up old backups (Keeping top 5)..."
cd "$BASE_BACKUP_DIR" && ls -dt */ | tail -n +6 | xargs -r rm -rf

echo "--- Backup Done $DATE ---"
sleep 2

