# Setup Guide

This guide walks you through installing and using the dev-environment flake on macOS, Linux, or WSL2.

## Supported platforms

- macOS (Intel and Apple Silicon)
- Linux (x86_64 and aarch64)
- WSL2 (Ubuntu recommended)

Native Windows is not supported; use WSL2.

## Install Nix

Check if Nix is installed:

```bash
command -v nix
```

If not installed:

macOS:

```bash
sh <(curl -L https://nixos.org/nix/install)
```

Linux / WSL2:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Restart your shell after install.

## Enable flakes

Add flakes support to your Nix config:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

## Clone and configure

```bash
git clone <YOUR_REPO_URL>
cd dev-environment
cp flake.config.example.nix flake.config.nix
```

Edit `flake.config.nix` with your values. The flake fails fast if this file is missing.

```nix
{
  username = "yourname";
  homeDirectory = "/home/yourname";
  profile = "dev"; # bare | server | dev

  darwinHost = "your-mac";
  darwinSystem = "aarch64-darwin"; # or x86_64-darwin

  linuxSystem = "x86_64-linux"; # or aarch64-linux
}
```

## Choose a profile

- `bare`: minimal CLI and productivity tools
- `server`: `bare` + build tools
- `dev`: full toolchain (languages, containers, infra)

You can switch profiles by changing `profile` in `flake.config.nix`.

## Use the dev shell

```bash
nix develop .#dev
```

Other profiles:

```bash
nix develop .#server
nix develop .#bare
```

## Install tools into your user profile

```bash
nix profile install .#dev
```

## Home Manager (Linux and WSL2)

```bash
nix run .#home-switch
```

## nix-darwin (macOS)

```bash
nix run .#darwin-switch
```

You may be prompted for sudo depending on your system configuration.

Note: On macOS, packages are installed via Home Manager to avoid double installs.

## Enable direnv

```bash
direnv allow
```

## Update the toolchain

```bash
nix flake update
nix run .#home-switch   # Linux/WSL2
nix run .#darwin-switch # macOS
```

## Customizing tools

Edit `flake.nix` and update the `toolProfiles` list to add or remove packages. The profiles control what is installed for `bare`, `server`, and `dev`.

## Troubleshooting

- `nix: command not found`: restart your shell or open a new terminal.
- `experimental-features` error: ensure flakes are enabled in `~/.config/nix/nix.conf`.
- `codex` missing: the package might not exist in your nixpkgs version.
- Docker installed but not running: start your Docker daemon separately (Docker Desktop or system service).
