#!/bin/bash
set -e
echo "Stopping any existing container..."
docker compose down || true
echo "Rebuilding and starting Windows 10 VM with fixed boot..."
docker compose up -d --build
echo "Done! Running 'docker logs -f windows10' so you can see live progress:"
docker logs -f windows10
