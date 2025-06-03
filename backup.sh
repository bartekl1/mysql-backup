#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/backup.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    exit 1
fi

# Import configuration
source "$CONFIG_FILE"

# Validate required config
if [[ -z "$DB_USER" || -z "$DB_PASSWORD" || -z "$DB_NAME" || -z "$LOCAL_BACKUP_DIR" ]]; then
    echo "❌ Missing required configuration in backup.conf"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$LOCAL_BACKUP_DIR"

# Generate timestamp
DATE=$(date +%Y%m%d)
TIME=$(date +%H%M%S)

# Set filename and full path
BASENAME="backup_${DB_NAME}_${DATE}_${TIME}.sql"
FULL_PATH="${LOCAL_BACKUP_DIR}/${BASENAME}"

# Dump MySQL database
echo "📦 Creating MySQL backup for database: $DB_NAME"
mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$FULL_PATH"

if [ $? -ne 0 ]; then
    echo "❌ mysqldump failed."
    exit 2
fi

# Optional compression
if [ "$ENABLE_COMPRESSION" = "true" ]; then
    echo "🗜️ Compressing backup file..."
    gzip "$FULL_PATH"
    FULL_PATH="${FULL_PATH}.gz"
    BASENAME="${BASENAME}.gz"
    if [ $? -ne 0 ]; then
        echo "❌ Compression failed."
        exit 3
    fi
    echo "✅ Backup compressed as: $FULL_PATH"
else
    echo "📄 Compression disabled. Backup saved as: $FULL_PATH"
fi

# Optional upload to remote via rclone
if [ "$UPLOAD_ENABLED" = "true" ]; then
    if [ -z "$REMOTE_BACKUP_DIR" ]; then
        echo "⚠️ Upload enabled but REMOTE_BACKUP_DIR is not set."
    else
        echo "☁️ Uploading backup to remote: $REMOTE_BACKUP_DIR"
        rclone copy "$FULL_PATH" "$REMOTE_BACKUP_DIR"
        if [ $? -eq 0 ]; then
            echo "✅ Upload completed successfully."
        else
            echo "❌ Upload failed."
        fi
    fi
else
    echo "🔕 Upload is disabled."
fi

# Cleanup old local backups
if [ "$KEEP_LOCAL_COPIES" -gt 0 ]; then
    echo "🧹 Cleaning up old backups (keeping last $KEEP_LOCAL_COPIES)..."
    EXT="sql"
    [ "$ENABLE_COMPRESSION" = "true" ] && EXT="sql.gz"
    ls -1t "$LOCAL_BACKUP_DIR"/backup_"${DB_NAME}"_*."$EXT" 2>/dev/null | tail -n +$((KEEP_LOCAL_COPIES+1)) | xargs -r rm --
else
    echo "📁 No cleanup configured. Keeping all local backups."
fi

echo "✅ Backup completed."
