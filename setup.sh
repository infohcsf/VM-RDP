#!/bin/bash
set -e

echo "=== Windows 10 Codespaces Setup ==="
echo "Checking virtualization support..."
if [ -e /dev/kvm ]; then
    echo "✓ /dev/kvm acceleration available!"
else
    echo "⚠ /dev/kvm not found. Will use software emulation (slower)."
fi

echo "Starting Windows 10 container with Docker Compose..."
docker compose up -d

echo ""
echo "=== Windows is starting! ==="
echo "1. Go to the PORTS tab in VS Code / Codespaces (bottom bar)."
echo "2. Find Port 8006 and click the Open in Browser icon (globe)."
echo "3. If accessing externally, right click port 8006 -> Port Visibility -> Public."
echo "4. The Windows setup will complete automatically in ~5-10 minutes."
