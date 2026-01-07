{
  description = "Reproducible dev environment for macOS, Linux, and WSL2";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, darwin }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      mkPkgs = system: import nixpkgs { inherit system; config.allowUnfree = true; };

      config = if builtins.pathExists ./flake.config.nix
        then import ./flake.config.nix
        else builtins.throw "Missing flake.config.nix. Copy flake.config.example.nix and set your values.";

      firstAvailable = pkgs: names:
        let
          available = builtins.filter (n: pkgs.lib.hasAttr n pkgs) names;
        in
          if available == [] then [] else [ pkgs.${builtins.head available} ];

      scriptPackages = pkgs: [];

      toolProfiles = pkgs:
        let
          core = with pkgs; [
            git
            gh
            curl
            wget
            ripgrep
            fd
            jq
            fzf
            zsh
            zsh-completions
            zsh-autosuggestions
            zsh-syntax-highlighting
            direnv
            nix-direnv
            just
            shellcheck
            sops
            age
          ];

          build = with pkgs; [
            gnumake
            openssl
            pkg-config
            unzip
            xz
            git-lfs
          ];

          langs = with pkgs; [
            python3
            pipx
            poetry
            nodejs
            pnpm
            yarn
          ];

          containers = with pkgs; [
            docker
            docker-compose
          ];

          infra = with pkgs; [
            terraform
            awscli2
            azure-cli
            google-cloud-sdk
            kubectl
          ];

          codex = firstAvailable pkgs [ "openai-codex" "codex" ];
        in
        {
          bare = core ++ (scriptPackages pkgs);
          server = core ++ build ++ (scriptPackages pkgs);
          dev = core ++ build ++ langs ++ containers ++ infra ++ codex ++ (scriptPackages pkgs);
        };

      mkToolList = pkgs: profile:
        if builtins.hasAttr profile (toolProfiles pkgs)
        then (toolProfiles pkgs).${profile}
        else builtins.throw "Invalid profile '${profile}'. Use one of: ${builtins.concatStringsSep \", \" (builtins.attrNames (toolProfiles pkgs))}";

      mkDevcontainerImage = pkgs: profile:
        let
          tools = mkToolList pkgs profile;
          imageEnv = pkgs.buildEnv {
            name = "devcontainer-${profile}-env";
            paths = tools ++ [ pkgs.bashInteractive pkgs.coreutils pkgs.cacert ];
          };
        in
        pkgs.dockerTools.buildLayeredImage {
          name = "dev-environment-${profile}";
          tag = "latest";
          contents = [ imageEnv ];
          config = {
            WorkingDir = "/workspaces/dev-environment";
            Cmd = [ "bash" ];
            Env = [
              "PATH=/bin"
              "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            ];
          };
          extraCommands = ''
            mkdir -p /workspaces/dev-environment
          '';
        };
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = mkPkgs system;
        in
        {
          bare = pkgs.mkShell { packages = mkToolList pkgs "bare"; };
          server = pkgs.mkShell { packages = mkToolList pkgs "server"; };
          dev = pkgs.mkShell { packages = mkToolList pkgs "dev"; };
          default = pkgs.mkShell { packages = mkToolList pkgs "dev"; };
        });

      packages = forAllSystems (system:
        let
          pkgs = mkPkgs system;
          devcontainerPackages = pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
            devcontainer-bare = mkDevcontainerImage pkgs "bare";
            devcontainer-server = mkDevcontainerImage pkgs "server";
            devcontainer-dev = mkDevcontainerImage pkgs "dev";
            devcontainer = mkDevcontainerImage pkgs config.profile;
          };
        in
        {
          bare = pkgs.buildEnv { name = "dev-env-bare"; paths = mkToolList pkgs "bare"; };
          server = pkgs.buildEnv { name = "dev-env-server"; paths = mkToolList pkgs "server"; };
          dev = pkgs.buildEnv { name = "dev-env"; paths = mkToolList pkgs "dev"; };
          default = pkgs.buildEnv { name = "dev-env"; paths = mkToolList pkgs "dev"; };
        } // devcontainerPackages);

      apps = forAllSystems (system:
        let
          pkgs = mkPkgs system;
          homeManager = home-manager.packages.${system}.home-manager;
          darwinRebuild = darwin.packages.${system}.darwin-rebuild;
        in
        {
          home-switch = {
            type = "app";
            program = toString (pkgs.writeShellScript "home-switch" ''
              if [[ "$(uname -s)" == "Darwin" ]]; then
                echo "home-switch is for Linux only. Use darwin-switch on macOS." >&2
                exit 1
              fi
              exec ${homeManager}/bin/home-manager switch --flake ${self}#${config.username}
            '');
          };

          darwin-switch = {
            type = "app";
            program = toString (pkgs.writeShellScript "darwin-switch" ''
              if [[ "$(uname -s)" != "Darwin" ]]; then
                echo "darwin-switch is for macOS only." >&2
                exit 1
              fi
              exec ${darwinRebuild}/bin/darwin-rebuild switch --flake ${self}#${config.darwinHost}
            '');
          };
        });

      homeConfigurations.${config.username} = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs config.linuxSystem;
        extraSpecialArgs = {
          username = config.username;
          homeDirectory = config.homeDirectory;
          toolPackages = mkToolList (mkPkgs config.linuxSystem) config.profile;
        };
        modules = [ ./home/home.nix ];
      };

      darwinConfigurations.${config.darwinHost} = darwin.lib.darwinSystem {
        system = config.darwinSystem;
        specialArgs = {
          username = config.username;
          homeDirectory = config.homeDirectory;
          toolPackages = mkToolList (mkPkgs config.darwinSystem) config.profile;
        };
        modules = [
          ./darwin/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${config.username} = import ./home/home.nix;
          }
        ];
      };
    };
}
