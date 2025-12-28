{ pkgs, config, ... }:

let
  githubPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCUgKLpvU8IYCiiAz1CflnBn2iLJJh6fM2Yop/QSU5Q natejaune@gmail.com";
in
{

  ".ssh/id_github.pub" = {
    text = githubPublicKey;
  };

  # Configure npm to install global packages to ~/.npm-packages
  # This allows installing packages not available in nixpkgs
  ".npmrc" = {
    text = ''
      prefix=~/.npm-packages
    '';
  };

  # Bootstrap script for npm packages not available in nixpkgs
  # Run this once after initial setup: ~/.local/bin/bootstrap-npm-packages
  ".local/bin/bootstrap-npm-packages" = {
    executable = true;
    text = ''
      #!/bin/bash
      set -e

      echo "Installing global npm packages not available in nixpkgs..."

      # Packages to install globally
      PACKAGES=(
        "claude-flow@latest"
        "agentic-flow@latest"
        "agentic-qe@latest"
      )

      for pkg in "''${PACKAGES[@]}"; do
        if npm list -g "$pkg" &>/dev/null; then
          echo "✓ $pkg already installed"
        else
          echo "Installing $pkg..."
          npm install -g "$pkg"
        fi
      done

      echo ""
      echo "Done! Packages installed to ~/.npm-packages"
    '';
  };

  # Initializes Emacs with org-mode so we can tangle the main config
  ".emacs.d/init.el" = {
    text = builtins.readFile ../shared/config/emacs/init.el;
  };

  # IMPORTANT: The Emacs configuration expects a config.org file at ~/.config/emacs/config.org
  # You can either:
  # 1. Copy the provided config.org to ~/.config/emacs/config.org
  # 2. Set EMACS_CONFIG_ORG environment variable to point to your config.org location
  # 3. Uncomment below to have Nix manage the file:
  #
  # ".config/emacs/config.org" = {
  #   text = builtins.readFile ../shared/config/emacs/config.org;
  # };
}
