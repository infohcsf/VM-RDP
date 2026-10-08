#!/bin/bash
set -e
echo "Building and starting Windows 10 VM..."
docker compose up -d --build
echo "Done! Windows 10 is running on port 6080 (noVNC)!"
