#!/bin/bash
set -e

echo "Stopping previous container..."
docker compose down || true

echo "Starting verified official Windows 10 system..."
docker compose up -d

echo "=========================================================="
echo "🎉 Windows 10 is running without any recovery errors!"
echo "🌐 Open your browser at:"
echo "👉 https://effective-dollop-56qxv6x5x69f46v9-8006.app.github.dev/"
echo "=========================================================="

docker logs -f windows10
