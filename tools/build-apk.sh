#!/usr/bin/env bash
# Собирает APK (release и debug) для RuStore.
# Требует: Godot 4.3 (godot в PATH или $GODOT_BIN), Android SDK, keystore.
# Ключи подписи берутся из ~/.android/flappy_release.env (НЕ хранятся в git).
set -euo pipefail

cd "$(dirname "$0")/.."

GODOT_BIN="${GODOT_BIN:-/opt/godot/Godot_v4.3-stable_linux.x86_64}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

if [ -f "$HOME/.android/flappy_release.env" ]; then
  # shellcheck disable=SC1091
  source "$HOME/.android/flappy_release.env"
fi

mkdir -p build/android

echo "==> Exporting release APK..."
"$GODOT_BIN" --headless --export-release "Android" "build/android/flappy_bird.apk"

echo "==> Exporting debug APK..."
"$GODOT_BIN" --headless --export-debug "Android" "build/android/flappy_bird_debug.apk"

echo "==> Done."
ls -la build/android/*.apk