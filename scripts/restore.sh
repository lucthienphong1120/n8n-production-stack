#!/bin/bash

BASE_BACKUP_DIR="/root/n8n/backup"
QDRANT_SNAP_DIR="/root/n8n/qdrant-snapshots"

echo "--- Bắt đầu khôi phục hệ thống (Bản mới nhất) ---"
# 1. Liệt kê các thư mục backup hiện có
cd "$BASE_BACKUP_DIR" || exit
options=($(ls -dt */ | sed 's/\///'))

if [ ${#options[@]} -eq 0 ]; then
    echo "LỖI: Không tìm thấy thư mục backup nào trong $BASE_BACKUP_DIR"
    exit 1
fi

echo "Danh sách bản backup:"
for i in "${!options[@]}"; do
    echo "$((i+1)). ${options[$i]}"
done

# 2. Prompt user chọn ngày
read -p "Chọn số thứ tự bản muốn khôi phục (1-${#options[@]}): " choice
if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#options[@]}" ]; then
    echo "Lựa chọn không hợp lệ. Thoát."
    exit 1
fi

SELECTED_DATE="${options[$((choice-1))]}"
TARGET_DIR="$BASE_BACKUP_DIR/$SELECTED_DATE"
echo "--- Đang chuẩn bị khôi phục từ ngày: $SELECTED_DATE ---"

# Function: Gộp file nếu thấy có bản chia nhỏ (.partaa, .partab...)
merge_files() {
    local file_path=$1
    if [ -f "${file_path}.partaa" ]; then
        echo "Phát hiện file chia nhỏ, đang gộp $(basename "$file_path")..."
        cat "${file_path}.part"* > "$file_path"
    fi
}

# 3. Thực hiện khôi phục
# --- Bước A: Postgres ---
echo "[1/3] Khôi phục Postgres..."
echo "Restoring Postgres..."
chmod -R 777 /root/n8n/postgres-data/
merge_files "$TARGET_DIR/postgres.sql.gz"
gzip -dc "$TARGET_DIR/postgres.sql.gz" | docker exec -i postgres psql -U postgres -d n8n
read -p "Nhấn [Enter] để tiếp tục..."

# --- Bước B: n8n ---
echo "[2/3] Khôi phục n8n workflows & credentials..."
merge_files "$TARGET_DIR/workflow.json"
merge_files "$TARGET_DIR/credentials.json"
docker exec -i n8n n8n import:workflow --input "backup/$SELECTED_DATE/workflow.json"
docker exec -i n8n n8n import:credentials --input "backup/$SELECTED_DATE/credentials.json"
read -p "Nhấn [Enter] để tiếp tục..."

# --- Bước C: Qdrant ---
echo "[3/3] Khôi phục Qdrant..."
merge_files "$TARGET_DIR/qdrant.snapshot"
cp "$TARGET_DIR/qdrant.snapshot" "$QDRANT_SNAP_DIR/restore.snapshot"
curl -s -X POST "http://localhost:6333/snapshots/recover" \
     -H "Content-Type: application/json" \
     -d '{"location": "file:///snapshots/restore.snapshot"}'
read -p "Nhấn [Enter] để tiếp tục..."

# 4. Hoàn tất
echo "--- Hoàn tất! Hãy khởi động lại n8n! ---"

