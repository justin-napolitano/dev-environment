# Devcontainer Template (Nix Overlay)

This template builds a project image on top of the base image from the
`dev-environment` repo.

## Requirements

- Build the base image once from the dev-environment repo:
  - `./scripts/build-devcontainer.sh dev`
- Docker and Nix installed on your machine.
 - If your base repo path is different, set `DEV_ENVIRONMENT_PATH`.

## Use

1) Copy this template into your project.
2) Adjust `nix/overlay.nix` for project-specific tools.
3) Update `.devcontainer/devcontainer.json` if needed.
4) Build the project image:

```bash
export DEV_ENVIRONMENT_PATH="/path/to/dev-environment"
./scripts/build-devcontainer.sh
```

Then in VS Code, reopen in container.
