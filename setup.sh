#!/bin/bash
set -e

echo "=========================================================="
echo "Starting Windows 10 (Tiny10) Automated Setup"
echo "=========================================================="

echo "1. Stopping any old containers..."
docker compose down || true

echo "2. Ensuring storage directory exists..."
mkdir -p ./data

echo "3. Downloading Tiny10 ISO directly on host (high-speed gigabit)..."
# Dockurr looks for /storage/tiny10.iso. Downloading it here completely bypasses container DNS issues.
if [ ! -s ./data/tiny10.iso ] || [ $(wc -c < ./data/tiny10.iso 2>/dev/null || echo 0) -lt 3000000000 ]; then
  echo "Downloading Tiny10 ISO (~3.8 GB) with resume support..."
  curl -L --retry 5 --retry-delay 2 -C -     "https://ia600508.us.archive.org/13/items/tiny-10-23-h2/tiny10%20x64%2023h2.iso"     -o ./data/tiny10.iso ||   curl -L --retry 5 --retry-delay 2 -C -     "https://archive.org/download/tiny-10-23-h2/tiny10%20x64%2023h2.iso"     -o ./data/tiny10.iso
fi

echo "4. Checking available disk space..."
df -h /workspaces

echo "5. Starting Windows container..."
docker compose up -d

echo "=========================================================="
echo "Windows 10 is booting and installing automatically!"
echo "Open in your browser at:"
echo "👉 https://effective-dollop-56qxv6x5x69f46v9-8006.app.github.dev/"
echo "=========================================================="
echo "Live logs (press Ctrl+C anytime to detach):"

docker logs -f windows10
