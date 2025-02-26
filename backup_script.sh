#!/bin/sh

# Get Variables from Railway Environment
GITHUB_USER="$RAILWAY_GITHUB_USER"
GITHUB_REPO="$RAILWAY_GITHUB_REPO"
GITHUB_TOKEN="$RAILWAY_GITHUB_TOKEN"
SOURCE_DIR="$RAILWAY_SOURCE_DIR"  # Tambahkan variabel untuk lokasi sumber
CLONE_DIR="/tmp/repo"  # Direktori sementara untuk kloning repo

# Pastikan SOURCE_DIR tidak kosong
if [ -z "$SOURCE_DIR" ]; then
  echo "Error: SOURCE_DIR is not set."
  exit 1
fi

# Remove old git history from the source folder
rm -rf "$SOURCE_DIR/.git"

# Clone repo (remove old clone first)
rm -rf "$CLONE_DIR"
git clone https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$GITHUB_REPO.git "$CLONE_DIR"

# Copy the contents of the source folder (not the folder itself)
cp -r "$SOURCE_DIR"/* "$CLONE_DIR/"

# Commit & push
cd "$CLONE_DIR" || exit
git add .
git commit -m "Automated upload of content from $SOURCE_DIR $(date)"
git push origin main
