#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v nix >/dev/null 2>&1; then
  echo "nix is not installed. Run scripts/bootstrap-linux-wsl.sh first." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed or not on PATH." >&2
  exit 1
fi

if [ $# -gt 1 ]; then
  echo "Usage: $0 [bare|server|dev]" >&2
  exit 1
fi

target="devcontainer"
if [ $# -eq 1 ]; then
  case "$1" in
    bare|server|dev)
      target="devcontainer-$1"
      ;;
    *)
      echo "Unknown profile: $1 (expected: bare, server, dev)" >&2
      exit 1
      ;;
  esac
fi

echo "Building image target: $target"
nix build ".#${target}"

echo "Loading image into docker..."
docker load < result

echo "Done."
