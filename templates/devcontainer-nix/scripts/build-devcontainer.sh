#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v nix >/dev/null 2>&1; then
  echo "nix is not installed." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed or not on PATH." >&2
  exit 1
fi

echo "Building project devcontainer image..."
nix build .#devcontainer

echo "Loading image into docker..."
docker load < result

echo "Done."
