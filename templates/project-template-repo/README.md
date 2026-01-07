# Project Template Repo (Devcontainer + Nix Overlay)

This is a minimal starter repo that builds a project devcontainer image on top of
the shared `dev-environment` base image.

## First time setup

1) Ensure the base image exists:

```bash
cd /home/jaybird/repos/dev-environment
./scripts/build-devcontainer.sh dev
```

2) If your base repo path is different, set:

```bash
export DEV_ENVIRONMENT_PATH="/path/to/dev-environment"
```

## Add project tools

Edit `nix/overlay.nix` and add project-specific packages.

## Build the project image

```bash
./scripts/build-devcontainer.sh
```

## Open in VS Code

Use "Dev Containers: Reopen in Container".
