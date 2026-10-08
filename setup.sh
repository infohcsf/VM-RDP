#!/bin/bash
set -e

sudo chown -R $USER:$USER . 2>/dev/null || true
mkdir -p ./iso ./data

# 1. Search for any existing 1.1GB+ ISO already downloaded on disk
ISO_FILE=""
for f in ./iso/os.iso ./iso/*.iso *.iso "Windows 10 Lite Edition 19H2 x64.iso"; do
  if [ -f "$f" ] && [ $(stat -c%s "$f" 2>/dev/null || echo 0) -gt 1000000000 ]; then
    ISO_FILE="$f"
    echo "✅ Found existing verified ISO: $f ($(stat -c%s "$f") bytes)"
    break
  fi
done

# 2. If not found, download it with resume
if [ -z "$ISO_FILE" ]; then
  echo "📥 ISO not found on disk, downloading Windows 10 Lite ISO..."
  wget -c --show-progress "https://archive.org/download/windows-10-lite-edition-19h2-x64/Windows%2010%20Lite%20Edition%2019H2%20x64.iso" -O "./iso/os.iso"
  ISO_FILE="./iso/os.iso"
fi

echo "Stopping previous container..."
docker compose down || true

echo "Starting container..."
docker compose up -d --build

echo "📦 Copying ISO directly into container (bypassing DinD mount issues)..."
docker cp "$ISO_FILE" windows10:/iso/os.iso
echo "✅ ISO copied successfully!"

# Signal start.sh to proceed
docker exec windows10 touch /iso/ready

echo "=========================================================="
echo "🎉 Windows 10 VM started successfully!"
echo "🌐 Open your browser at:"
echo "👉 https://effective-dollop-56qxv6x5x69f46v9-6080.app.github.dev/vnc.html"
echo "=========================================================="

docker logs -f windows10
