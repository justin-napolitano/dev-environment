#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

USERNAME_DEFAULT="${USER:-}"
HOME_DIRECTORY_DEFAULT="${HOME:-}"
PROFILE_DEFAULT="dev"
LINUX_SYSTEM_DEFAULT="x86_64-linux"

prompt_with_default() {
  local var_name="$1"
  local prompt="$2"
  local default="$3"
  local value=""

  read -r -p "$prompt [$default]: " value
  if [ -z "$value" ]; then
    value="$default"
  fi
  printf -v "$var_name" "%s" "$value"
}

prompt_with_default USERNAME "Username" "${USERNAME:-$USERNAME_DEFAULT}"
prompt_with_default HOME_DIRECTORY "Home directory" "${HOME_DIRECTORY:-$HOME_DIRECTORY_DEFAULT}"
prompt_with_default PROFILE "Profile (bare/server/dev)" "${PROFILE:-$PROFILE_DEFAULT}"
prompt_with_default LINUX_SYSTEM "Linux system (x86_64-linux/aarch64-linux)" "${LINUX_SYSTEM:-$LINUX_SYSTEM_DEFAULT}"

prompt_with_default BOOTSTRAP_WRITE_CONFIG "Overwrite flake.config.nix if it exists? (0/1)" "${BOOTSTRAP_WRITE_CONFIG:-0}"

write_config() {
  cat > "$ROOT_DIR/flake.config.nix" <<EOF
{
  username = "$USERNAME";
  homeDirectory = "$HOME_DIRECTORY";
  profile = "$PROFILE"; # bare | server | dev

  # macOS only
  darwinHost = "your-mac";
  darwinSystem = "aarch64-darwin"; # or x86_64-darwin

  # Linux only
  linuxSystem = "$LINUX_SYSTEM"; # or aarch64-linux
}
EOF
}

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix not found. Installing (multi-user daemon)..."
  sh <(curl -L https://nixos.org/nix/install) --daemon
  if [ -e /etc/profile.d/nix.sh ]; then
    # Load Nix into the current shell so subsequent commands work.
    # shellcheck disable=SC1091
    . /etc/profile.d/nix.sh
  elif [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

mkdir -p "$HOME/.config/nix"
if ! grep -q "experimental-features = .*nix-command.*flakes" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
  echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
fi

if [ ! -f "$ROOT_DIR/flake.config.nix" ]; then
  echo "Creating flake.config.nix"
  write_config
else
  if [ "${BOOTSTRAP_WRITE_CONFIG:-0}" = "1" ]; then
    echo "Overwriting flake.config.nix (BOOTSTRAP_WRITE_CONFIG=1)"
    write_config
  else
    echo "flake.config.nix already exists; leaving as-is."
  fi
fi

echo "Running Home Manager switch..."
nix run .#home-switch

prompt_with_default LAUNCH_DEV_SHELL "Launch dev shell now? (0/1)" "${LAUNCH_DEV_SHELL:-0}"
if [ "$LAUNCH_DEV_SHELL" = "1" ]; then
  echo "Starting dev shell..."
  nix develop .#dev
fi

echo "Done. If nix command is not found, restart your shell."
