#!/bin/sh

# Wait until MinIO is healthy
while ! mc alias set myminio http://minio:9000 \
      "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" > /dev/null 2>&1; do
  echo "Waiting for MinIO..."
  sleep 2
done

# Make buckets if not exists
mc mb myminio/n8n-bucket --ignore-existing
mc mb myminio/public-bucket --ignore-existing
mc anonymous set download myminio/public-bucket

# Check if access key exists
if ! mc admin accesskey info myminio "$N8N_ACCESS_KEY" > /dev/null 2>&1; then
  echo "Creating access key for n8n..."
  mc admin accesskey create myminio "$MINIO_ROOT_USER" \
    --access-key "$N8N_ACCESS_KEY" \
    --secret-key "$N8N_SECRET_KEY" || true
else
  echo "Access key already exists, skipping creation"
fi

echo "MinIO bootstrap completed"

