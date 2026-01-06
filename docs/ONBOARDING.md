# Team Onboarding Checklist

Use this checklist to get a new machine ready quickly.

## 1) Install prerequisites

- Install Nix (see `docs/SETUP.md`).
- Enable flakes in `~/.config/nix/nix.conf`.

## 2) Clone and configure

```bash
git clone <YOUR_REPO_URL>
cd dev-environment
cp flake.config.example.nix flake.config.nix
```

Edit `flake.config.nix` with:
- `username`
- `homeDirectory`
- `profile`
- `darwinHost` / `darwinSystem` (macOS)
- `linuxSystem` (Linux/WSL2)

## 3) Enter a dev shell

```bash
nix develop .#dev
```

## 4) Apply Home Manager or nix-darwin

Linux / WSL2:

```bash
nix run .#home-switch
```

macOS:

```bash
nix run .#darwin-switch
```

## 5) Enable direnv (optional but recommended)

```bash
direnv allow
```

## 6) Verify tools

```bash
git --version
node --version
python --version
terraform version
```

## 7) Update later

```bash
nix flake update
nix run .#home-switch   # Linux/WSL2
nix run .#darwin-switch # macOS
```
