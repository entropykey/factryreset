#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/bigfile.bin"
SIZE_MB=${1:-1024}

# Check for adb
if ! command -v adb >/dev/null 2>&1; then
  echo "Error: adb not found in PATH"
  exit 1
fi

# Check if a device is connected
echo "Checking device..."
if ! adb get-state >/dev/null 2>&1; then
  echo "No connected device found or not authorized"
  exit 1
fi

# Create file if missing
if [ ! -f "$FILE" ]; then
  echo "Creating $SIZE_MB MB random file..."
  dd if=/dev/urandom of="$FILE" bs=1M count="$SIZE_MB" status=progress
else
  echo "Using existing file: $FILE"
fi

echo "Starting push loop (will stop when storage is full)..."
i=1
while adb push "$FILE" "/sdcard/bigfile_${i}.bin" >/dev/null 2>&1; do
  printf "pushed #%d\r" "$i"
  i=$((i+1))
done
echo -e "\nStopped at copy #$i (storage full or error)."

# Quick cleanup
echo "Deleting pushed files..."
adb shell 'rm -f /sdcard/bigfile_*.bin' || true

echo "Done. Empty Files app Trash manually if needed."
echo "Now run factory reset via phone UI or recovery."
