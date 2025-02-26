#!/bin/sh

# Install git jika belum ada
apt-get update && apt-get install -y git

# Get Variables from Railway Environment
GITHUB_USER="$RAILWAY_GITHUB_USER"
GITHUB_REPO="$RAILWAY_GITHUB_REPO"
GITHUB_TOKEN="$RAILWAY_GITHUB_TOKEN"
SOURCE_DIR="$RAILWAY_SOURCE_DIR"
CLONE_DIR="/tmp/repo"

# Pastikan SOURCE_DIR tidak kosong
if [ -z "$SOURCE_DIR" ]; then
  echo "Error: SOURCE_DIR is not set."
  exit 1
fi

# Hapus riwayat Git lama
rm -rf "$SOURCE_DIR/.git"

# Hapus folder clone lama & buat ulang
rm -rf "$CLONE_DIR"
mkdir -p "$CLONE_DIR"

# Clone repo dengan pengecekan error
git clone https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$GITHUB_REPO.git "$CLONE_DIR" || { echo "Git clone failed"; exit 1; }

# Copy isi dari SOURCE_DIR ke repo
cp -r "$SOURCE_DIR"/* "$CLONE_DIR/"

# Commit & push
cd "$CLONE_DIR" || { echo "Failed to enter directory $CLONE_DIR"; exit 1; }
git add .
git commit -m "Automated upload of content from $SOURCE_DIR $(date)"
git push origin main
