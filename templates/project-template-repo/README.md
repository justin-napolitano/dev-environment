# Project Template Repo (Devcontainer + Nix Overlay)

This is a minimal starter repo that builds a project devcontainer image on top of
the shared `dev-environment` base image. Prefer running
`scripts/create-devcontainer-project.sh` from the root dev-environment repo to
copy this template automatically.

## First time setup

1) Ensure the base image exists:

```bash
cd /home/jaybird/repos/dev-environment
./scripts/build-devcontainer.sh dev
```

2) If you are copying this template manually, set one of:

```bash
export DEV_ENVIRONMENT_PATH="/path/to/dev-environment"
# or
export DEV_ENVIRONMENT_URL="github:your-org/dev-environment"
```

## Add project tools

Edit `nix/overlay.nix` and add project-specific packages.

## Build the project image

```bash
./scripts/build-devcontainer.sh
```

## Open in VS Code

Use "Dev Containers: Reopen in Container".
