#!/bin/sh

echo "Checking required environment variables..."
echo "GITHUB_USER: $GITHUB_USER"
echo "GITHUB_REPO: $GITHUB_REPO"
echo "GITHUB_TOKEN: ${GITHUB_TOKEN:0:4}****"
echo "SOURCE_DIR: $SOURCE_DIR"
echo "CLONE_DIR: $CLONE_DIR"

# Cek apakah Git tersedia
if ! command -v git >/dev/null 2>&1; then
  echo "Git is not installed. Installing now..."
  apt-get update && apt-get install -y git || { echo "Failed to install git"; exit 1; }
fi

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
if ! git clone https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$GITHUB_REPO.git "$CLONE_DIR"; then
  echo "❌ Git clone failed. Check if the token and repo name are correct."
  exit 1
fi

# Pastikan direktori target benar
if [ ! -d "$CLONE_DIR" ]; then
  echo "❌ Error: Clone directory $CLONE_DIR does not exist."
  exit 1
fi

# Copy isi dari SOURCE_DIR ke repo
if ! cp -r "$SOURCE_DIR"/* "$CLONE_DIR/"; then
  echo "❌ Error copying files"
  exit 1
fi

# Set Git user identity untuk commit
git config --global user.email "backup-bot@railway.app"
git config --global user.name "Railway Backup Bot"

# Commit & push
cd "$CLONE_DIR" || { echo "❌ Failed to enter directory $CLONE_DIR"; exit 1; }

# Cek apakah ada perubahan sebelum commit
if git diff --quiet && git diff --staged --quiet; then
  echo "✅ No changes to commit. Backup skipped."
  exit 0
fi

git add .
git commit -m "Automated upload of content from $SOURCE_DIR on $(date)"

# Push dengan pengecekan error
if ! git push origin main; then
  echo "❌ Git push failed. Check your token, branch, or repo permissions."
  exit 1
fi

echo "✅ Backup successfully pushed to GitHub!"
