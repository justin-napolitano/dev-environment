let
  defaultDevEnvUrl = "__DEV_ENV_URL__";
  devEnvPath = builtins.getEnv "DEV_ENVIRONMENT_PATH";
  devEnvUrlEnv = builtins.getEnv "DEV_ENVIRONMENT_URL";
  devEnvInput =
    if devEnvPath != "" then "path:${devEnvPath}"
    else if devEnvUrlEnv != "" then devEnvUrlEnv
    else defaultDevEnvUrl;
in
{
  description = "Project devcontainer image with Nix overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dev-environment.url = devEnvInput;
  };

  outputs = { self, nixpkgs, dev-environment }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import ./nix/overlay.nix) ];
        config.allowUnfree = true;
      };

      baseImage = dev-environment.packages.${system}.devcontainer-dev;
      projectEnv = pkgs.buildEnv {
        name = "project-dev-env";
        paths = (pkgs.projectExtraPkgs or []) ++ [ pkgs.bashInteractive pkgs.coreutils ];
      };
    in
    {
      packages.${system}.devcontainer = pkgs.dockerTools.buildLayeredImage {
        name = "project-dev";
        tag = "latest";
        fromImage = baseImage;
        contents = [ projectEnv ];
        config = {
          WorkingDir = "/workspaces/project";
          Cmd = [ "bash" ];
        };
        extraCommands = ''
          mkdir -p /workspaces/project
        '';
      };
    };
}
