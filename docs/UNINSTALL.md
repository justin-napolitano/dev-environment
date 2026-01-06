# Uninstall Nix

This guide removes Nix from macOS or Linux/WSL2. It is destructive.

## Warning

This deletes:
- `/nix`
- Nix daemon services
- User Nix profiles and channels

macOS notes:
- Removes `nixbld` users/groups
- Removes `/Library/LaunchDaemons/org.nixos.nix-daemon.plist`
- Backs up `/etc/synthetic.conf` and removes only the `nix` entry
- Edits `/etc/shells` to remove Nix paths

Linux notes:
- Stops/disables `nix-daemon` systemd units when present
- Removes `/etc/profile.d/nix.sh` and `/etc/profile.d/nix-daemon.sh`

## Scripted removal

Run the helper script:

```bash
./scripts/uninstall-nix.sh
```

You may be prompted for sudo.

Dry run (prints actions without removing anything):

```bash
./scripts/uninstall-nix.sh --dry-run
```

## Confirmation prompt

The script asks for confirmation before it deletes anything. Use `--dry-run` to review actions first.

## Manual notes

If something is left behind:

- macOS: check `/Library/LaunchDaemons/org.nixos.nix-daemon.plist`
- Linux: check `systemctl status nix-daemon`
- User config: `~/.config/nix`
