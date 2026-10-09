#!/bin/bash
set -e

echo "=========================================================="
echo "🚀 Windows 10 LTSC High-Speed Setup (Microsoft Azure CDN)"
echo "=========================================================="

# 1. Stop any old containers
echo "1. Stopping old containers..."
docker compose down || true

# 2. Cleanup slow/partial archive.org downloads
echo "2. Cleaning up old partial files..."
rm -f ./data/tiny10.iso* ./data/*.aria2 2>/dev/null || true
mkdir -p ./data

# 3. Ensure multi-threaded accelerator is available
echo "3. Ensuring high-speed downloader (aria2) is installed..."
if ! command -v aria2c >/dev/null 2>&1; then
  sudo apt-get update -qq && sudo apt-get install -y -qq aria2 2>/dev/null || true
fi

# 4. Download official lightweight Windows 10 LTSC directly from Microsoft Azure CDN (50-100 MB/s)
ISO_FILE="./data/win10x64-enterprise-ltsc-eval.iso"
ISO_URL="https://software-download.microsoft.com/download/pr/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso"

echo "4. Downloading Windows 10 LTSC from Microsoft Azure CDN..."
if [ ! -s "$ISO_FILE" ] || [ $(wc -c < "$ISO_FILE" 2>/dev/null || echo 0) -lt 4500000000 ]; then
  if command -v aria2c >/dev/null 2>&1; then
    echo "⚡ Downloading with 16 parallel connections (super-fast)..."
    aria2c -x 16 -s 16 -j 16 -k 2M --file-allocation=none --summary-interval=5       "$ISO_URL" -d ./data -o win10x64-enterprise-ltsc-eval.iso
  else
    echo "⚡ Downloading via curl with resume support..."
    curl -L --retry 5 -C - "$ISO_URL" -o "$ISO_FILE"
  fi
fi

# 5. Check free disk space
echo "5. Available disk space:"
df -h /workspaces

# 6. Start Windows container
echo "6. Starting Windows 10 LTSC container..."
docker compose up -d

echo "=========================================================="
echo "🎉 Windows 10 LTSC is running and installing automatically!"
echo "🌐 Connect to your desktop in your browser at:"
echo "👉 https://effective-dollop-56qxv6x5x69f46v9-8006.app.github.dev/"
echo "=========================================================="
echo "Live logs (press Ctrl+C anytime to detach):"

docker logs -f windows10
