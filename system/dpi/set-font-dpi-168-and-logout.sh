#!/usr/bin/env bash
set -euo pipefail

config="$HOME/.config/kcmfonts"
state="$HOME/APP/.fontdpi.orig"
target="168"

current=""
if [[ -f "$config" ]]; then
  current=$(awk -F= '/^forceFontDPI=/{print $2}' "$config")
fi

if [[ ! -f "$state" ]]; then
  if [[ "$current" =~ ^[0-9]+$ ]]; then
    echo "$current" > "$state"
  else
    echo "96" > "$state"
  fi
fi

if [[ -f "$config" ]]; then
  if grep -q '^forceFontDPI=' "$config"; then
    sed -i "s/^forceFontDPI=.*/forceFontDPI=$target/" "$config"
  else
    printf "\n[General]\nforceFontDPI=%s\n" "$target" >> "$config"
  fi
else
  mkdir -p "$HOME/.config"
  printf "[General]\nforceFontDPI=%s\n" "$target" > "$config"
fi

uid="$(id -u)"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$uid}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"

if command -v qdbus6 >/dev/null 2>&1; then
  qdbus6 org.kde.ksmserver /KSMServer logout 0 0 0
elif command -v qdbus >/dev/null 2>&1; then
  qdbus org.kde.ksmserver /KSMServer logout 0 0 0
elif command -v dbus-send >/dev/null 2>&1; then
  dbus-send --session --dest=org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout int32:0 int32:0 int32:0
elif command -v loginctl >/dev/null 2>&1; then
  loginctl terminate-user "$USER"
else
  echo "DPI set to $target. Please log out to apply."
fi
