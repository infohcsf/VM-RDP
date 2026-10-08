#!/bin/bash
set -e

# Start noVNC
websockify --web /novnc 6080 localhost:5900 &

echo "⏳ Waiting for ISO to be loaded into /iso/os.iso..."
while [ ! -f "/iso/ready" ] && [ ! -s "/iso/os.iso" ]; do
  sleep 1
done

echo "✅ ISO confirmed: $(ls -lh /iso/os.iso)"

# Patch BOOTFIX.BIN in-place so Windows skips "Press any key" and boots directly into setup
python3 -c '
with open("/iso/os.iso", "r+b") as f:
    f.seek(722879)
    chunk = f.read(11)
    if chunk == b"BOOTFIX.BIN":
        f.seek(722879)
        f.write(b"NOBTFIX.BIN")
        print("✅ Patched BOOTFIX.BIN: Windows will auto-boot without prompt!")
    else:
        print("BOOTFIX.BIN status:", chunk)
' || true

# Fresh clean 100GB disk image so no corrupted recovery BCD boots
rm -f /data/disk.qcow2
echo "💽 Creating fresh 100GB virtual disk..."
qemu-img create -f qcow2 "/data/disk.qcow2" 100G

# Windows-optimized KVM & CPU flags
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

echo "⚙️ Starting Windows 10 VM with ${SMP_CORES} CPU cores and ${MEMORY} RAM"

# Start QEMU directly booting from CD-ROM
qemu-system-x86_64 \
  $KVM_ARG \
  -machine q35,accel=kvm:tcg \
  -cpu $CPU_ARG \
  -m $MEMORY \
  -smp $SMP_CORES \
  -vga std \
  -usb -device usb-tablet \
  -boot order=d,menu=off \
  -cdrom /iso/os.iso \
  -drive file=/data/disk.qcow2,format=qcow2,if=ide \
  -netdev user,id=net0,hostfwd=tcp::3389-:3389 \
  -device e1000,netdev=net0 \
  -display vnc=:0 \
  -name "Windows10_VM"

tail -f /dev/null
