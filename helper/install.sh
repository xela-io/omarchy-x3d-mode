#!/bin/sh
# Installs (or with --remove, uninstalls) the passwordless switching helper.
set -eu

bin=/usr/local/bin/omarchy-x3d-mode-set
policy=/usr/share/polkit-1/actions/io.xela.omarchy-x3d-mode.policy
dir=$(dirname "$(readlink -f "$0")")

if [ "${1:-}" = "--remove" ]; then
  sudo rm -f "$bin" "$policy"
  echo "Removed the X3D mode helper."
  exit 0
fi

sudo install -Dm755 -o root -g root "$dir/omarchy-x3d-mode-set" "$bin"
sudo install -Dm644 -o root -g root "$dir/io.xela.omarchy-x3d-mode.policy" "$policy"
echo "Installed the X3D mode helper. Switching no longer asks for a password."
