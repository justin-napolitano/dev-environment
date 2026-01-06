# Managing .env and secrets

You can do both:
- keep local `.env` files for each project
- use encrypted secrets for anything shared

## Local `.env` files (per project)

Best practice:
- Commit `.env.example` with placeholder values.
- Add `.env` and `.env.local` to `.gitignore`.
- Keep real secrets out of git.

With direnv, add an `.envrc` in each project:

```bash
dotenv_if_exists
```

This loads `.env` and `.env.local` if they exist. `dotenv_if_exists` is provided by the Home Manager config in this repo.

## Encrypted secrets (shared)

Use `sops` + `age` for encrypted `.env` files that can live in git.

### 1) Create an age key

```bash
age-keygen -o ~/.config/age/keys.txt
```

Get the public key:

```bash
grep "public key" ~/.config/age/keys.txt
```

### 2) Create `.sops.yaml` in your repo

```yaml
keys:
  - &primary age1yourpublickeyhere
creation_rules:
  - path_regex: \.env\.enc$
    key_groups:
      - age:
          - *primary
```

### 3) Encrypt an env file

```bash
sops -e .env > .env.enc
```

Commit `.env.enc` to git. Keep `.env` and `.env.local` ignored.

### 4) Decrypt when needed

```bash
sops -d .env.enc > .env
```

### Optional: load encrypted env with direnv

Add to `.envrc`:

```bash
if [[ -f .env.enc ]]; then
  sops -d .env.enc > .env
fi

dotenv_if_exists
```

Use this only if you are comfortable writing decrypted secrets to disk.

## Summary

- Local secrets: `.env` + `.env.local`, never commit.
- Shared secrets: `sops` + `age`, commit `.env.enc`.
- Use `direnv` to load `.env` safely per project.
