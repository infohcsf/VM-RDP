#!/bin/bash
set -e

sudo chown -R $USER:$USER . 2>/dev/null || true
mkdir -p ./iso ./data

# Find downloaded ISO if saved in current directory or with original name
if [ -f "Windows 10 Lite Edition 19H2 x64.iso" ]; then
  echo "Moving ISO from root to ./iso/os.iso..."
  mv "Windows 10 Lite Edition 19H2 x64.iso" ./iso/os.iso
fi

for f in *.iso; do
  if [ -f "$f" ] && [ "$f" != "os.iso" ]; then
    echo "Found ISO: $f -> moving to ./iso/os.iso"
    mv "$f" ./iso/os.iso
  fi
done

for f in ./iso/*.iso; do
  if [ -f "$f" ] && [ "$f" != "./iso/os.iso" ]; then
    echo "Renaming $f to ./iso/os.iso"
    mv "$f" ./iso/os.iso
  fi
done

sudo chmod -R 777 ./iso ./data

echo "Checking ISO file:"
ls -lh ./iso/

if [ ! -s "./iso/os.iso" ]; then
  echo "ISO not found in ./iso/os.iso! Downloading..."
  wget -c --show-progress "https://archive.org/download/windows-10-lite-edition-19h2-x64/Windows%2010%20Lite%20Edition%2019H2%20x64.iso" -O "./iso/os.iso"
  sudo chmod 777 ./iso/os.iso
fi

echo "Stopping previous container..."
docker compose down || true

echo "Starting Windows 10 VM..."
docker compose up -d --build

echo "=========================================================="
echo "✅ Windows 10 is running!"
echo "🌐 Open your browser at:"
echo "👉 https://effective-dollop-56qxv6x5x69f46v9-6080.app.github.dev/vnc.html"
echo "=========================================================="

docker logs -f windows10
