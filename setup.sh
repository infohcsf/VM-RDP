#!/bin/bash
set -e

echo "=========================================================="
echo "Starting Windows Desktop Setup - Tiny10"
echo "=========================================================="

echo "1. Stopping any old containers..."
docker compose down || true

echo "2. Configuring Docker DNS for Azure GitHub Codespaces..."
sudo mkdir -p /etc/docker
cat << 'EOF' | sudo tee /etc/docker/daemon.json >/dev/null
{
  "dns": ["168.63.129.16", "1.1.1.1", "8.8.8.8"]
}
EOF
sudo systemctl restart docker 2>/dev/null || sudo service docker restart 2>/dev/null || true
sleep 3

echo "3. Freeing up workspace space..."
docker system prune -f 2>/dev/null || true
mkdir -p ./data

echo "4. Current available disk space:"
df -h /workspaces

echo "5. Launching Windows 10 (Tiny10 lightweight)..."
docker compose up -d

echo "=========================================================="
echo "Windows 10 is running and installing automatically!"
echo "Open in your browser at:"
echo "https://effective-dollop-56qxv6x5x69f46v9-8006.app.github.dev/"
echo "=========================================================="
echo "Showing live logs (press Ctrl+C anytime to exit log view):"

docker logs -f windows10
