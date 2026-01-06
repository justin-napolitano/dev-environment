# Custom Script Repos

This repo can pull scripts from other repos as Nix flake inputs, so they stay up to date and land on your PATH.

## Pattern

1) Each script repo exposes a package (via its own flake).
2) This repo adds that flake as an input.
3) The script package is included in every profile.

## Example: script repo flake

```nix
{
  description = "update-certs script";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      mkPkgs = system: import nixpkgs { inherit system; };
    in {
      packages = forAllSystems (system:
        let pkgs = mkPkgs system;
        in {
          default = pkgs.writeShellApplication {
            name = "update_certs";
            text = builtins.readFile ./update_certs.sh;
          };
        });
    };
}
```

## Add the script repo as an input

In this repo’s `flake.nix`, add an input:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  update-certs.url = "github:you/update-certs";
};
```

## Expose packages in this repo

In `flake.nix`, update `scriptPackages`:

```nix
scriptPackages = pkgs: [
  inputs.update-certs.packages.${pkgs.system}.default
];
```

Now the script is included in `bare`, `server`, and `dev` profiles.

## Update scripts

```bash
nix flake update
```

This pulls the latest commits for all script repos. Pin versions via `flake.lock` if you need stability.
