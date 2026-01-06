# Tools Guide

This guide explains how tools are defined and how to customize what gets installed.

## Where tools live

All tools are defined in `flake.nix` under `toolProfiles`:

- `bare`: minimal CLI and productivity tools
- `server`: `bare` + build tools
- `dev`: full toolchain (languages, containers, infra)

These lists are the single source of truth for all profiles.

## Add a tool

1) Open `flake.nix`.
2) Find the profile list you want (e.g., `core`, `build`, `langs`, `containers`, `infra`).
3) Add the Nix package name to the list.

Example:

```nix
langs = with pkgs; [
  python3
  nodejs
  rustup
];
```

## Remove a tool

Delete it from the list in `flake.nix`.

## Change which profile is active

Set `profile` in `flake.config.nix`:

```nix
{
  profile = "server";
}
```

## Find package names

Use Nix search:

```bash
nix search nixpkgs <name>
```

## Notes

- If a package is not found on your platform, you may need to use a different name or guard it by platform.
- `codex` uses a fallback: it tries `openai-codex`, then `codex` if available.
