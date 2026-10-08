#!/bin/bash
set -e

# Check for KVM support
if [ -e /dev/kvm ]; then
  echo "✅ KVM acceleration available"
  KVM_ARG="-enable-kvm"
  CPU_ARG="host"
  MEMORY=${MEMORY:-4G}
  SMP_CORES=${CPU_CORES:-2}
else
  echo "⚠️ KVM not available - using slower emulation mode"
  KVM_ARG=""
  CPU_ARG="qemu64"
  MEMORY="2G"
  SMP_CORES=1
fi

# Ensure full 1.2GB ISO is present
ISO_SIZE=$(stat -c%s "/iso/os.iso" 2>/dev/null || echo 0)
if [ "$ISO_SIZE" -lt 1000000000 ]; then
  echo "📥 Downloading Windows 10 ISO (1.2GB)..."
  rm -f /iso/os.iso
  curl -L -A "Mozilla/5.0" --progress-bar -o "/iso/os.iso" "$ISO_URL"
fi

# Create disk image if not exists
if [ ! -f "/data/disk.qcow2" ]; then
  echo "💽 Creating 100GB virtual disk..."
  qemu-img create -f qcow2 "/data/disk.qcow2" 100G
fi

echo "⚙️ Starting Windows 10 VM with ${SMP_CORES} CPU cores and ${MEMORY} RAM"

# Start QEMU with standard PC machine and guaranteed CD boot (-cdrom and -boot d)
qemu-system-x86_64 \
  $KVM_ARG \
  -cpu $CPU_ARG \
  -m $MEMORY \
  -smp $SMP_CORES \
  -vga std \
  -usb -device usb-tablet \
  -boot d \
  -drive file=/data/disk.qcow2,format=qcow2,if=ide \
  -cdrom /iso/os.iso \
  -netdev user,id=net0,hostfwd=tcp::3389-:3389 \
  -device e1000,netdev=net0 \
  -display vnc=:0 \
  -name "Windows10_VM" &

# Start noVNC
sleep 3
websockify --web /novnc 6080 localhost:5900 &

echo "===================================================="
echo "🌐 Connect via VNC: http://localhost:6080"
echo "🔌 After install, use RDP: localhost:3389"
echo "===================================================="

tail -f /dev/null
