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

There is a template you can copy into any project:

```
templates/devcontainer-nix
```

It builds a project image from `dev-environment-dev:latest` and lets you add
project-specific packages via `nix/overlay.nix`.

If your base repo path is not `/home/jaybird/repos/dev-environment`, set:

```bash
export DEV_ENVIRONMENT_PATH="/path/to/dev-environment"
```

## Template repo

You can also use a ready-to-clone starter in:

```
templates/project-template-repo
```
