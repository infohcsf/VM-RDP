# Windows 10 in GitHub Codespaces

Run a virtualized Windows 10 desktop directly inside your GitHub Codespace using Docker and KVM.

## Quick Start inside Codespace Terminal:

```bash
chmod +x setup.sh
./setup.sh
```

Or run directly:

```bash
docker compose up -d
```

## How to View the Windows Desktop:
1. Open the **PORTS** tab in your Codespace (bottom panel).
2. Look for port **`8006`**.
3. Right click port `8006` -> Set **Port Visibility** to **Public** (or open while logged in).
4. Click the globe icon 🌐 to open the web viewer in a new browser tab.
