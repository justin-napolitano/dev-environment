#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/templates/project-template-repo"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Template repo not found at $TEMPLATE_DIR" >&2
  exit 1
fi

prompt_with_default() {
  local var_name="$1"
  local prompt_text="$2"
  local default_value="$3"
  local input=""

  if [[ -n "$default_value" ]]; then
    read -r -p "$prompt_text [$default_value]: " input || true
  else
    read -r -p "$prompt_text: " input || true
  fi

  if [[ -z "$input" ]]; then
    input="$default_value"
  fi

  printf -v "$var_name" '%s' "$input"
}

normalize_remote_url() {
  local remote="$1"

  case "$remote" in
    github:*)
      echo "$remote"
      return
      ;;
    git@github.com:*.git)
      local slug="${remote#git@github.com:}"
      slug="${slug%.git}"
      echo "github:${slug}"
      return
      ;;
    git@github.com:*)
      local slug="${remote#git@github.com:}"
      echo "github:${slug}"
      return
      ;;
    https://github.com/*.git)
      local slug="${remote#https://github.com/}"
      slug="${slug%.git}"
      echo "github:${slug}"
      return
      ;;
    https://github.com/*)
      local slug="${remote#https://github.com/}"
      echo "github:${slug}"
      return
      ;;
    ssh://git@github.com/*.git)
      local slug="${remote#ssh://git@github.com/}"
      slug="${slug%.git}"
      echo "github:${slug}"
      return
      ;;
    ssh://git@github.com/*)
      local slug="${remote#ssh://git@github.com/}"
      echo "github:${slug}"
      return
      ;;
  esac

  echo ""
}

detect_default_dev_env_reference() {
  local remote=""
  if command -v git >/dev/null 2>&1; then
    remote=$(git -C "$ROOT_DIR" config --get remote.origin.url 2>/dev/null || true)
  fi

  if [[ -n "$remote" ]]; then
    local normalized="$(normalize_remote_url "$remote")"
    if [[ -n "$normalized" ]]; then
      echo "$normalized"
      return
    fi
  fi

  echo "path:$ROOT_DIR"
}

project_name_default="project-dev"
prompt_with_default PROJECT_NAME "Project name" "${PROJECT_NAME:-$project_name_default}"

default_project_dir="$ROOT_DIR/../$PROJECT_NAME"
prompt_with_default PROJECT_DIR "Project directory" "${PROJECT_DIR:-$default_project_dir}"

default_dev_env_ref="$(detect_default_dev_env_reference)"
prompt_with_default DEV_ENV_REFERENCE "dev-environment flake reference" "${DEV_ENV_REFERENCE:-$default_dev_env_ref}"

prompt_with_default INIT_GIT "Initialize a git repo? (0/1)" "${INIT_GIT:-1}"

if [[ -z "$PROJECT_DIR" ]]; then
  echo "Project directory is required." >&2
  exit 1
fi

if [[ -e "$PROJECT_DIR" ]]; then
  echo "Target directory $PROJECT_DIR already exists. Choose another path." >&2
  exit 1
fi

mkdir -p "$PROJECT_DIR"

tar -C "$TEMPLATE_DIR" -cf - . | tar -C "$PROJECT_DIR" -xf -

if [[ ! -f "$PROJECT_DIR/flake.nix" ]]; then
  echo "flake.nix not found in new project at $PROJECT_DIR" >&2
  exit 1
fi

# Replace placeholder dev-environment URL with the provided value.
escaped_dev_env_ref="$(printf '%s' "$DEV_ENV_REFERENCE" | sed -e 's/[\\&/]/\\&/g')"
perl -0pi -e "s#__DEV_ENV_URL__#${escaped_dev_env_ref}#g" "$PROJECT_DIR/flake.nix"

if [[ "$INIT_GIT" == "1" ]]; then
  (cd "$PROJECT_DIR" && git init && git add .)
fi

cat <<EOF
Project scaffolded at: $PROJECT_DIR
dev-environment reference: $DEV_ENV_REFERENCE

Next steps:
  - Edit nix/overlay.nix to add project-specific tools.
  - Run ./scripts/build-devcontainer.sh inside the project to build the image.
  - (Optional) Create the first git commit.
EOF
