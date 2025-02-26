#!/bin/sh

echo "🚀 Memulai Railway GitHub Backup Bot..."

# Pastikan Railway Environment Variables sudah diatur
if [ -z "$RAILWAY_GITHUB_USER" ] || [ -z "$RAILWAY_GITHUB_REPO" ] || [ -z "$RAILWAY_GITHUB_TOKEN" ]; then
  echo "❌ Error: Railway GitHub environment variables tidak diatur."
  exit 1
fi

# Konfigurasi variabel
GITHUB_USER="$RAILWAY_GITHUB_USER"
GITHUB_REPO="$RAILWAY_GITHUB_REPO"
GITHUB_TOKEN="$RAILWAY_GITHUB_TOKEN"
SOURCE_DIR="$RAILWAY_SOURCE_DIR"
CLONE_DIR="/tmp/repo"
REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"

echo "📌 Repository: $GITHUB_USER/$GITHUB_REPO"
echo "📂 Source Directory: $SOURCE_DIR"
echo "📦 Clone Directory: $CLONE_DIR"

# Pastikan SOURCE_DIR ada
if [ ! -d "$SOURCE_DIR" ]; then
  echo "❌ Error: Directory $SOURCE_DIR tidak ditemukan!"
  exit 1
fi

# Hapus folder clone lama & buat ulang
rm -rf "$CLONE_DIR"
mkdir -p "$CLONE_DIR"

# Clone repository (jika ada)
if git clone "$REPO_URL" "$CLONE_DIR"; then
  echo "✅ Repository berhasil di-clone!"
else
  echo "❌ Gagal meng-clone repository. Periksa token atau izin repository."
  exit 1
fi

# Pastikan repo berhasil di-clone
if [ ! -d "$CLONE_DIR/.git" ]; then
  echo "❌ Error: Gagal meng-clone repo dengan benar!"
  exit 1
fi

# Masuk ke folder repo sebelum konfigurasi Git
cd "$CLONE_DIR" || { echo "❌ Gagal masuk ke direktori clone."; exit 1; }

# Tambahkan safe.directory untuk menghindari error kepemilikan mencurigakan
git config --global --add safe.directory "$CLONE_DIR"

# 🔥 Set Git Credential Helper agar tidak meminta username/password
git config --global credential.helper store
echo "https://${GITHUB_TOKEN}:x-oauth-basic@github.com" > ~/.git-credentials
chmod 600 ~/.git-credentials

# Set identitas Git
git config user.name "Railway Backup Bot"
git config user.email "backup-bot@railway.app"

# Fungsi untuk menjalankan backup
backup_data() {
    while true; do
        echo "🕒 Memulai backup data..."

        # Copy isi dari SOURCE_DIR ke CLONE_DIR
        rsync -av --delete "$SOURCE_DIR/" "$CLONE_DIR/"

        # Masuk ke folder repository
        cd "$CLONE_DIR" || { echo "❌ Gagal masuk ke $CLONE_DIR"; exit 1; }

        # Stash perubahan lokal sebelum menarik perubahan dari remote
        git stash || echo "ℹ️ Tidak ada perubahan untuk di-stash."

        # Sinkronisasi dengan remote
        echo "🔄 Mengambil perubahan terbaru dari GitHub..."
        git pull origin main --rebase || { echo "❌ Gagal menarik perubahan dari GitHub."; exit 1; }

        # Terapkan kembali perubahan yang telah di-stash
        git stash pop || echo "ℹ️ Tidak ada perubahan untuk dipulihkan."

        # Cek apakah ada perubahan sebelum commit
        if git diff --quiet && git diff --staged --quiet; then
            echo "✅ Tidak ada perubahan baru. Backup tidak diperlukan."
        else
            echo "📌 Perubahan terdeteksi, melakukan commit..."
            git add .
            git commit -m "🚀 Automated backup: $(date +'%Y-%m-%d %H:%M:%S')"

            echo "📤 Mengirim backup ke GitHub..."
            if git push origin main; then
                echo "✅ Backup berhasil di-push ke GitHub!"
            else
                echo "❌ Gagal mengirim backup. Periksa koneksi atau izin repository."
                exit 1
            fi
        fi

        echo "✅ Backup selesai. Menunggu 1 menit sebelum backup berikutnya..."
        sleep 60
    done
}

# Jalankan backup di background
backup_data &
