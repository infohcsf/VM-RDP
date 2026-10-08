#!/bin/bash
set -e

# Start noVNC
websockify --web /novnc 6080 localhost:5900 &

echo "⏳ Waiting for ISO to be loaded into /iso/os.iso..."
while [ ! -f "/iso/ready" ] && [ ! -s "/iso/os.iso" ]; do
  sleep 1
done

echo "✅ ISO confirmed: $(ls -lh /iso/os.iso)"

# Windows-optimized KVM & CPU flags to prevent winload.exe 0xc0000225 error
if [ -e /dev/kvm ]; then
  echo "✅ KVM acceleration available"
  KVM_ARG="-enable-kvm"
  CPU_ARG="host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time"
  MEMORY=${MEMORY:-4G}
  SMP_CORES=${CPU_CORES:-2}
else
  echo "⚠️ KVM not available - using slower emulation mode"
  KVM_ARG=""
  CPU_ARG="qemu64"
  MEMORY="2G"
  SMP_CORES=1
fi

if [ ! -f "/data/disk.qcow2" ]; then
  echo "💽 Creating 100GB virtual disk..."
  qemu-img create -f qcow2 "/data/disk.qcow2" 100G
fi

echo "⚙️ Starting Windows 10 VM with ${SMP_CORES} CPU cores and ${MEMORY} RAM"

# Start QEMU on Q35 PCIe machine with explicit ide-cd and ide-hd buses
qemu-system-x86_64 \
  $KVM_ARG \
  -machine q35,accel=kvm:tcg \
  -cpu $CPU_ARG \
  -m $MEMORY \
  -smp $SMP_CORES \
  -vga std \
  -usb -device usb-tablet \
  -boot d \
  -device ide-cd,bus=ide.0,drive=cdrom \
  -drive file=/iso/os.iso,if=none,id=cdrom,media=cdrom \
  -device ide-hd,bus=ide.1,drive=harddisk \
  -drive file=/data/disk.qcow2,if=none,id=harddisk,format=qcow2 \
  -netdev user,id=net0,hostfwd=tcp::3389-:3389 \
  -device e1000,netdev=net0 \
  -display vnc=:0 \
  -name "Windows10_VM"

tail -f /dev/null
