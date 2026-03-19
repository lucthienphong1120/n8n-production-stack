#!/bin/bash

LOG_FILE="/var/log/n8n-backup.log"

# Logging (Stdout + log file)
exec > >(while IFS= read -r line; do echo "$(date '+%Y-%m-%d %H:%M:%S') $line"; done | tee -a "$LOG_FILE") 2>&1

# Di chuyển đến thư mục chứa Git repo
cd /root/n8n/

# Kiểm tra nếu có thay đổi mới thực hiện commit
echo "Tự động commit thay đổi lên Git"
if [[ -n $(git status -s) ]]; then
    # Tự động pull thay đổi
    git pull --ff

    # Thêm tất cả thay đổi
    git add -A

    # Commit với nội dung kèm thời gian hiện tại
    git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"

    # Push lên nhánh hiện tại (thường là main hoặc master)
    git push origin $(git rev-parse --abbrev-ref HEAD)

    echo "Đã push thành công vào lúc $(date)"
else
    echo "Không có thay đổi nào để commit."
fi

sleep 2
