{ pkgs, username, homeDirectory, toolPackages, ... }:
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "23.11";

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.autosuggestion.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";
    plugins = [
      "git"
      "aws"
      "gcloud"
      "npm"
      "yarn"
      "pnpm"
      "python"
      "pip"
      "poetry"
      "fzf"
      "direnv"
      "docker"
      "docker-compose"
      "kubectl"
      "terraform"
    ];
  };
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.stdlib = ''
    dotenv_if_exists() {
      if [[ -f .env ]]; then
        dotenv
      fi
      if [[ -f .env.local ]]; then
        dotenv .env.local
      fi
    }
  '';

  home.packages = toolPackages;
}
