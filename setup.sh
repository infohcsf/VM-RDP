#!/bin/bash
set -e

echo "1. Stopping old containers..."
docker compose down || true

echo "2. Cleaning up all old bloated disk data (freeing 25+ GB)..."
sudo rm -rf ./data/* ./iso/* 2>/dev/null || true
docker system prune -af 2>/dev/null || true

echo "3. Free disk space is now:"
df -h /workspaces

echo "4. Starting ultra-lightweight Tiny10 (uses only 6GB disk, boots in 2 mins)..."
docker compose up -d

echo "=========================================================="
echo "🎉 Tiny10 is running! It will finish setup in ~2 minutes!"
echo "🌐 Open your browser at:"
echo "👉 https://effective-dollop-56qxv6x5x69f46v9-8006.app.github.dev/"
echo "=========================================================="

docker logs -f windows10
