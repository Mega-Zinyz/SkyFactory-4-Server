#!/bin/bash

echo "📌 Checking required environment variables..."
echo "GITHUB_USER: $RAILWAY_GITHUB_USER"
echo "GITHUB_REPO: $RAILWAY_GITHUB_REPO"
echo "GITHUB_TOKEN: $(echo "$RAILWAY_GITHUB_TOKEN" | cut -c1-4)****"
echo "SOURCE_DIR: $RAILWAY_SOURCE_DIR"
CLONE_DIR="/tmp/repo"

# Cek apakah Git tersedia
if ! command -v git >/dev/null 2>&1; then
  echo "⚠️ Git is not installed. Installing now..."
  apt-get update && apt-get install -y git || { echo "❌ Failed to install git"; exit 1; }
fi

# Pastikan SOURCE_DIR tidak kosong
if [ -z "$RAILWAY_SOURCE_DIR" ]; then
  echo "❌ Error: SOURCE_DIR is not set."
  exit 1
fi

# Debug: Cek isi SOURCE_DIR sebelum copy
echo "📂 Listing SOURCE_DIR before copy:"
ls -l "$RAILWAY_SOURCE_DIR"

# Hapus riwayat Git lama
rm -rf "$RAILWAY_SOURCE_DIR/.git"

# Hapus folder clone lama & buat ulang
rm -rf "$CLONE_DIR"
mkdir -p "$CLONE_DIR"

# Clone repo dengan pengecekan error
if ! git clone https://${RAILWAY_GITHUB_TOKEN}@github.com/${RAILWAY_GITHUB_USER}/${RAILWAY_GITHUB_REPO}.git "$CLONE_DIR"; then
  echo "❌ Git clone failed. Check if the token and repo name are correct."
  exit 1
fi

# Pastikan direktori target benar
if [ ! -d "$CLONE_DIR" ]; then
  echo "❌ Error: Clone directory $CLONE_DIR does not exist."
  exit 1
fi

# Debug: Cek isi CLONE_DIR sebelum copy
echo "📂 Listing CLONE_DIR before copy:"
ls -l "$CLONE_DIR"

# Copy isi dari SOURCE_DIR ke repo
if ! cp -r "$RAILWAY_SOURCE_DIR"/* "$CLONE_DIR/"; then
  echo "❌ Error copying files"
  exit 1
fi

# Debug: Cek isi CLONE_DIR setelah copy
echo "📂 Listing CLONE_DIR after copy:"
ls -l "$CLONE_DIR"

# Masuk ke folder repo
cd "$CLONE_DIR" || { echo "❌ Failed to enter directory $CLONE_DIR"; exit 1; }

# ✅ Set identitas Git setelah masuk ke repo
git config user.email "backup-bot@railway.app"
git config user.name "Railway Backup Bot"

# Tambahkan semua perubahan ke staging
git add --all

# Debug: Cek status Git sebelum commit
echo "🔍 Checking git status before commit..."
git status

# Cek apakah ada perubahan sebelum commit
if git diff --quiet --cached; then
  echo "✅ No changes to commit. Backup skipped."
  exit 0
fi

# Debug: Tampilkan perubahan jika tidak ada yang dikomit
echo "🔍 Git diff output:"
git diff --cached

# Commit perubahan
git commit -m "🚀 Automated upload of content from $RAILWAY_SOURCE_DIR on $(date)"

# Push dengan pengecekan error
if ! git push origin main; then
  echo "❌ Git push failed. Check your token, branch, or repo permissions."
  exit 1
fi

echo "✅ Backup successfully pushed to GitHub!"
