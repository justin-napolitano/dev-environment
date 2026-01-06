# dev-environment

Reproducible dev environment for macOS, Linux, and WSL2 using Nix flakes, Home Manager, and nix-darwin.

## Quick start (all-in-one)

1) Install Nix:

macOS:

```bash
sh <(curl -L https://nixos.org/nix/install)
```

Linux / WSL2:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

2) Enable flakes:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

3) Clone and configure:

```bash
git clone <YOUR_REPO_URL>
cd dev-environment
cp flake.config.example.nix flake.config.nix
```

4) Enter a dev shell:

```bash
nix develop .#dev
```

5) Apply Home Manager or nix-darwin:

Linux / WSL2:

```bash
nix run .#home-switch
```

macOS:

```bash
nix run .#darwin-switch
```

## Profiles

- `bare` minimal core tools
- `server` core + build tools
- `dev` full toolchain (default)

## .env and secrets workflow

### Local-only `.env`

1) Add to `.gitignore` in each project:

```gitignore
.env
.env.local
```

2) Add `.env.example` with placeholders.

3) Add `.envrc` in the project:

```bash
dotenv_if_exists
```

This loads `.env` and `.env.local` if present.

### Encrypted secrets with sops + age

1) Create an age key:

```bash
age-keygen -o ~/.config/age/keys.txt
```

2) Create `.sops.yaml`:

```yaml
keys:
  - &primary age1yourpublickeyhere
creation_rules:
  - path_regex: \\.env\\.enc$
    key_groups:
      - age:
          - *primary
```

3) Encrypt and commit:

```bash
sops -e .env > .env.enc
```

4) Decrypt when needed:

```bash
sops -d .env.enc > .env
```

### Optional: auto-decrypt for direnv

```bash
if [[ -f .env.enc ]]; then
  sops -d .env.enc > .env
fi

dotenv_if_exists
```

Use this only if you are comfortable writing decrypted secrets to disk.

## Full setup guide

See `docs/SETUP.md` for installation, configuration, updates, and troubleshooting.

## More docs

- `docs/TOOLS.md` for adding/removing tools and profiles
- `docs/ONBOARDING.md` for team onboarding checklist
- `docs/UNINSTALL.md` for removing Nix from a machine
- `docs/SECRETS.md` for managing `.env` files and encrypted secrets
- `docs/SCRIPTS.md` for wiring script repos into the toolchain

## Notes

- `codex` is included if available as a Nix package (tries `openai-codex` then `codex`).
- Docker is installed as a CLI package; services are not enabled by default.
