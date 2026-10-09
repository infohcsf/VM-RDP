#!/bin/bash
set -e

echo "=========================================================="
echo "🚀 Windows 10 LTSC Setup (Microsoft Azure CDN)"
echo "=========================================================="

# 1. Stop any old containers
echo "1. Stopping old containers..."
docker compose down || true

# 2. Cleanup any corrupt partial qcow2 files if previous run crashed
rm -f ./data/data.qcow2 2>/dev/null || true
mkdir -p ./data

# 3. Check existing ISO
ISO_FILE="./data/win10x64-enterprise-ltsc-eval.iso"
ISO_URL="https://software-download.microsoft.com/download/pr/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso"

if [ -s "$ISO_FILE" ] && [ $(wc -c < "$ISO_FILE" 2>/dev/null || echo 0) -gt 4500000000 ]; then
  echo "2. ISO file already downloaded and verified (4.8 GB)!"
else
  echo "2. Ensuring high-speed downloader (aria2) is installed..."
  if ! command -v aria2c >/dev/null 2>&1; then
    sudo apt-get update -qq && sudo apt-get install -y -qq aria2 2>/dev/null || true
  fi

  echo "3. Downloading Windows 10 LTSC from Microsoft Azure CDN..."
  if command -v aria2c >/dev/null 2>&1; then
    aria2c -x 16 -s 16 -j 16 -k 2M --file-allocation=none --summary-interval=5 \
      "$ISO_URL" -d ./data -o win10x64-enterprise-ltsc-eval.iso
  else
    curl -L --retry 5 -C - "$ISO_URL" -o "$ISO_FILE"
  fi
fi

# 4. Check free disk space
echo "3. Available disk space:"
df -h /workspaces

# 5. Start Windows container
echo "4. Starting Windows 10 LTSC container..."
docker compose up -d

echo "=========================================================="
echo "🎉 Windows 10 LTSC is booting up!"
echo "🌐 Connect to your desktop in your browser at:"
echo "👉 https://effective-dollop-56qxv6x5x69f46v9-8006.app.github.dev/"
echo "=========================================================="
echo "Live logs (press Ctrl+C anytime to detach):"

docker logs -f windows10
