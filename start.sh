#!/bin/bash
set -e

# Start noVNC immediately so browser can always connect
websockify --web /novnc 6080 localhost:5900 &

echo "⏳ Waiting for ISO to be loaded into /iso/os.iso..."
while [ ! -f "/iso/ready" ] && [ ! -s "/iso/os.iso" ]; do
  sleep 1
done

echo "✅ ISO confirmed: $(ls -lh /iso/os.iso)"

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

# Create disk image if not exists
if [ ! -f "/data/disk.qcow2" ]; then
  echo "💽 Creating 100GB virtual disk..."
  qemu-img create -f qcow2 "/data/disk.qcow2" 100G
fi

echo "⚙️ Starting Windows 10 VM with ${SMP_CORES} CPU cores and ${MEMORY} RAM"

# Start QEMU with guaranteed CD-ROM boot
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
  -name "Windows10_VM"

tail -f /dev/null
