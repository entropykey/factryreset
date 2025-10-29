#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/bigfile.bin"
SIZE_MB=${1:-1024}

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found"; exit 1
fi

echo "Checking device..."
adb devices | grep -v "List" || { echo "No device found"; exit 1; }

[ -f "$FILE" ] || dd if=/dev/urandom of="$FILE" bs=1M count="$SIZE_MB" status=progress

echo "Pushing files until storage full..."
i=1
while adb push "$FILE" /sdcard/bigfile_${i}.bin >/dev/null 2>&1; do
  echo "pushed #$i"
  i=$((i+1))
done
echo "Stopped at copy #$i"

echo "Deleting pushed files..."
adb shell rm /sdcard/bigfile_*.bin || true

echo "Empty Files app Trash manually if needed."
echo "Now run factory reset via phone UI or recovery."

