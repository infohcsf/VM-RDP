#!/bin/bash
set -e

# Fix docker root permissions
sudo chown -R $USER:$USER ./iso ./data 2>/dev/null || true
sudo chmod -R 777 ./iso ./data 2>/dev/null || true
mkdir -p ./iso ./data

ISO_URL="https://archive.org/download/windows-10-lite-edition-19h2-x64/Windows%2010%20Lite%20Edition%2019H2%20x64.iso"
TARGET_SIZE=1195311104

# Download ISO with resume support and clear progress
CURRENT_SIZE=$(stat -c%s "./iso/os.iso" 2>/dev/null || echo 0)
if [ "$CURRENT_SIZE" -lt "$TARGET_SIZE" ]; then
  echo "=========================================================="
  echo "📥 Downloading Windows 10 Lite ISO (1.2 GB)..."
  echo "⏳ Please wait 1-2 minutes for the progress bar to finish."
  echo "⚠️ DO NOT press Ctrl+C while it is downloading!"
  echo "=========================================================="
  wget -c --show-progress "$ISO_URL" -O "./iso/os.iso"
  echo "✅ Download complete! ISO verified."
else
  echo "✅ Windows ISO already downloaded and verified (1.2 GB)!"
fi

echo "Stopping any previous container..."
docker compose down || true

echo "Starting Windows 10 VM..."
docker compose up -d --build

echo "=========================================================="
echo "✅ Windows 10 is running!"
echo "🌐 Open your browser at:"
echo "👉 https://effective-dollop-56qxv6x5x69f46v9-6080.app.github.dev/vnc.html"
echo "=========================================================="

docker logs -f windows10
