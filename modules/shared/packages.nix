{ pkgs }:

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

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Media-related packages
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
  terraform
  kubectl
  awscli2
  lazygit
  fzf
  direnv
  
  # Programming languages and runtimes
  go
  rustc
  cargo
  openjdk

  # Python packages
  python3
  virtualenv

  # AI/LLM tools
  ollama
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
