{ pkgs, lib ? pkgs.lib }:

let
  spotctl = pkgs.callPackage ./spotctl.nix {};
  maestro = pkgs.callPackage ./maestro.nix {};
  zenflow = pkgs.callPackage ./zenflow.nix {};
in

with pkgs; [
  # General packages for development and system management
  alacritty
  bash-completion
  bat
  btop
  coreutils
  killall
  openssh
  sqlite
  wget
  zip

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  libfido2
  _1password-cli  # 1Password CLI (op)

  # Cloud-related tools and SDKs
  docker
  docker-compose
  lima        # Linux VM manager for macOS
  colima      # Container runtime (Docker Desktop alternative)
  lazydocker  # Terminal UI for Docker containers
  spotctl     # CLI for Spot by NetApp (Rackspace Spot)

  # Media-related packages
  yt-dlp      # YouTube and video downloader
  emacs-all-the-icons-fonts
  dejavu_fonts
  ffmpeg
  fd
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-color-emoji
  meslo-lgs-nf

  # Node.js development tools
  nodejs_24
  nodePackages.pnpm
  nodePackages.wrangler
  bun         # Fast JavaScript runtime, bundler, and package manager
  claude-code

  # Text and terminal utilities
  htop
  jetbrains-mono
  jq
  ripgrep
  tree
  tmux
  unrar
  unzip
  zsh-powerlevel10k
  
  # Development tools
  curl
  gh
  ngrok        # Secure tunnels to localhost
  terraform
  kubectl
  awscli2
  flyctl      # Fly.io CLI
  cloudflared # Cloudflare Tunnel client
  lazygit
  fzf
  direnv
  
  # Programming languages and runtimes
  go
  rustup      # Rust toolchain manager (provides rustc, cargo, etc.)
  openjdk

  # Databases
  postgresql_16  # PostgreSQL 16

  # Python packages
  python3
  (lib.lowPrio python311)  # Python 3.11 (lower priority to avoid conflicts with python3)
  virtualenv
  uv          # Fast Python package manager
  ruff        # Fast Python linter and formatter
  poetry      # Python dependency management
  python3Packages.cython  # C-extensions for Python

  # Compilers and toolchains
  llvm        # LLVM compiler infrastructure

  # AI/LLM tools
  ollama
  maestro     # AI agent command center
  zenflow     # Multi-agent orchestration for production engineering
  python3Packages.llm
  python3Packages.llm-anthropic
  python3Packages.llm-deepseek
  python3Packages.llm-gemini
  python3Packages.llm-grok
  python3Packages.llm-ollama
  python3Packages.llm-openrouter
  python3Packages.llm-perplexity
  # Note: llm-openai is not needed - OpenAI support is built into the base llm package
]
