#!/bin/sh

# Get Variables from Railway Environment
GITHUB_USER="$RAILWAY_GITHUB_USER"
GITHUB_REPO="$RAILWAY_GITHUB_REPO"
GITHUB_TOKEN="$RAILWAY_GITHUB_TOKEN"

# Remove old git history from the world folder
rm -rf /data/world/.git

# Clone repo (remove old clone first)
rm -rf /tmp/repo
git clone https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$GITHUB_REPO.git /tmp/repo

# Copy the contents of the world folder (not the folder itself)
cp -r /data/world/* /tmp/repo/

# Commit & push
cd /tmp/repo || exit
git add .
git commit -m "Automated upload of world content $(date)"
git push origin main
