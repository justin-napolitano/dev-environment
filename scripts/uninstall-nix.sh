#!/usr/bin/env bash
set -euo pipefail

dry_run=false
if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=true
fi

confirm() {
  if $dry_run; then
    return 0
  fi
  echo "This will permanently remove Nix and delete /nix. Continue? [y/N]"
  read -r reply
  if [[ "$reply" != "y" && "$reply" != "Y" ]]; then
    echo "Aborted."
    exit 1
  fi
}

run() {
  if $dry_run; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

os="$(uname -s)"

confirm

if [[ "$os" == "Darwin" ]]; then
  if command -v nix >/dev/null 2>&1; then
    run sudo /nix/var/nix/profiles/default/bin/nix-env --uninstall nix
  fi

  if [[ -e /nix ]]; then
    run sudo rm -rf /nix
  fi

  run sudo dscl . -delete /Users/nixbld 2>/dev/null || true
  for i in {1..32}; do
    run sudo dscl . -delete /Users/nixbld$i 2>/dev/null || true
  done

  run sudo dscl . -delete /Groups/nixbld 2>/dev/null || true

  if [[ -f /etc/synthetic.conf ]]; then
    run sudo cp /etc/synthetic.conf /etc/synthetic.conf.backup-before-nix-removal
    run sudo sed -i '' '/^[[:space:]]*nix[[:space:]]*$/d' /etc/synthetic.conf
  fi
  run sudo rm -f /etc/nix/nix.conf
  run sudo rm -f /etc/nix/nix.conf.backup-before-nix
  run sudo rm -rf /etc/nix
  run sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
  run sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist

  run sudo sed -i '' '/nix/d' /etc/shells 2>/dev/null || true

  run rm -rf "$HOME/.nix-profile" "$HOME/.nix-defexpr" "$HOME/.nix-channels" "$HOME/.config/nix"
else
  if command -v systemctl >/dev/null 2>&1; then
    run sudo systemctl stop nix-daemon.service nix-daemon.socket 2>/dev/null || true
    run sudo systemctl disable nix-daemon.service nix-daemon.socket 2>/dev/null || true
  fi

  if command -v nix >/dev/null 2>&1; then
    run sudo /nix/var/nix/profiles/default/bin/nix-env --uninstall nix 2>/dev/null || true
  fi

  run sudo rm -rf /nix
  run sudo rm -rf /etc/nix
  run sudo rm -f /etc/profile.d/nix.sh /etc/profile.d/nix-daemon.sh

  run rm -rf "$HOME/.nix-profile" "$HOME/.nix-defexpr" "$HOME/.nix-channels" "$HOME/.config/nix"
fi

echo "Nix removed. You may need to restart your shell."
