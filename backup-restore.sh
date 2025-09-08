#!/bin/bash
set -e

BACKUP_DIR="/opt/vps-backup"
STATE_FILE="/var/lib/tailscale/tailscaled.state"
TIMESTAMP=$(date -u +'%Y-%m-%d_%H-%M-%S-UTC')
TMP_DIR="/tmp/vps-backup-$TIMESTAMP"
BACKUP_ZIP="/tmp/backup-$TIMESTAMP.zip"
DRIVE_REMOTE="gdrive"
DRIVE_FOLDER="VPS-Backups/dilshant/$TIMESTAMP"

echo "📦 Creating backup at $TIMESTAMP"

# Prepare backup dir
mkdir -p "$TMP_DIR/data"

# Save tailscale state if exists
if [ -f "$STATE_FILE" ]; then
  cp "$STATE_FILE" "$TMP_DIR/data/"
fi

# Copy previous VPS data if exists
if [ -d "$BACKUP_DIR" ]; then
  cp -r "$BACKUP_DIR"/* "$TMP_DIR/" || true
fi

# Zip everything
cd "$TMP_DIR"
zip -r "$BACKUP_ZIP" .
cd -

echo "✅ Backup created: $BACKUP_ZIP"

# Upload to Google Drive
echo "☁️ Uploading to Google Drive..."
rclone mkdir "$DRIVE_REMOTE:$DRIVE_FOLDER"
rclone copy "$BACKUP_ZIP" "$DRIVE_REMOTE:$DRIVE_FOLDER/"

echo "✅ Backup uploaded: $DRIVE_REMOTE:$DRIVE_FOLDER/backup-$TIMESTAMP.zip"

# Cleanup
rm -rf "$TMP_DIR" "$BACKUP_ZIP"
