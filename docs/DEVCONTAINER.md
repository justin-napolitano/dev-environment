# Devcontainer Images

This repo can build a Docker image for use with VS Code Dev Containers.
The image is built from the tool profiles defined in `flake.nix`.

## Build the image

From this repo:

```bash
./scripts/build-devcontainer.sh        # uses profile from flake.config.nix
./scripts/build-devcontainer.sh dev    # explicit profile: bare|server|dev
```

The image name is `dev-environment-<profile>:latest`.

## Use in a project

In your project, reference the image from `.devcontainer/devcontainer.json`:

```json
{
  "name": "project-dev",
  "image": "dev-environment-dev:latest",
  "workspaceFolder": "/workspaces/project",
  "mounts": [
    "source=${localWorkspaceFolder},target=/workspaces/project,type=bind,consistency=cached"
  ]
}
```

If you want project-specific tools, build a project image that layers on top of
`dev-environment-<profile>:latest`.

## Project template

The easiest way to create a per-project image is to run:

```bash
./scripts/create-devcontainer-project.sh
```

The script copies `templates/project-template-repo`, injects the correct
dev-environment reference (prefers your git remote, falls back to
`path:/abs/path`), and optionally initializes git. The resulting repo already
contains `.devcontainer`, the flake, and helper scripts—just push it and tell
teammates to reopen in container.

If you prefer to copy the template manually, use:

```
templates/devcontainer-nix
```

It builds a project image from `dev-environment-dev:latest` and lets you add
project-specific packages via `nix/overlay.nix`.

When copying templates manually, set either `DEV_ENVIRONMENT_PATH` (local path)
or `DEV_ENVIRONMENT_URL` (flake URL such as `github:your-org/dev-environment`)
before building so the flake can locate the shared toolchain.

## Template repo

You can also use a ready-to-clone starter in:

```
templates/project-template-repo
```
