#!/bin/bash
set -e

# Fix docker root permissions
sudo chown -R $USER:$USER ./iso ./data 2>/dev/null || true
sudo chmod -R 777 ./iso ./data 2>/dev/null || true
mkdir -p ./iso ./data

ISO_URL="https://archive.org/download/windows-10-lite-edition-19h2-x64/Windows%2010%20Lite%20Edition%2019H2%20x64.iso"

# Check if ISO already exists on host and is at least 1GB
ISO_SIZE=$(stat -c%s "./iso/os.iso" 2>/dev/null || echo 0)
if [ "$ISO_SIZE" -lt 1000000000 ]; then
  echo "📥 Downloading Windows 10 Lite ISO (1.2GB)..."
  sudo rm -f ./iso/os.iso
  curl -L -A "Mozilla/5.0" --progress-bar -o "./iso/os.iso" "$ISO_URL"
  echo "✅ ISO download complete!"
else
  echo "✅ Windows ISO already downloaded!"
fi

echo "Stopping any existing container..."
docker compose down || true

echo "Starting Windows 10 VM..."
docker compose up -d --build

echo "Done! Windows 10 is running! Showing live logs:"
docker logs -f windows10
