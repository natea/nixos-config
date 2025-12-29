# NixOS Configuration

A declarative system configuration for macOS (nix-darwin) and NixOS using Nix flakes, home-manager, and Homebrew integration.

## Overview

This repository manages system configuration declaratively, meaning your entire system setup is defined in code and can be reproduced on any machine.

### Key Technologies

- **Nix Flakes** - Reproducible, hermetic builds with locked dependencies
- **nix-darwin** - NixOS-style configuration for macOS
- **home-manager** - User environment and dotfile management
- **nix-homebrew** - Declarative Homebrew cask and formula management
- **agenix** - Secret management with age encryption

## Directory Structure

```
.
├── apps/                    # Build and deployment scripts
│   ├── aarch64-darwin/      # Apple Silicon Mac scripts
│   ├── x86_64-darwin/       # Intel Mac scripts
│   └── x86_64-linux/        # Linux scripts
├── hosts/
│   ├── darwin/              # macOS host configuration
│   └── nixos/               # NixOS host configuration
├── modules/
│   ├── darwin/              # macOS-specific modules
│   │   ├── casks.nix        # Homebrew casks (GUI apps)
│   │   ├── packages.nix     # Darwin-specific Nix packages
│   │   ├── files.nix        # Darwin-specific dotfiles
│   │   ├── home-manager.nix # Home-manager configuration
│   │   └── dock/            # Dock configuration
│   ├── nixos/               # NixOS-specific modules
│   └── shared/              # Shared between darwin and nixos
│       ├── packages.nix     # Cross-platform Nix packages
│       ├── files.nix        # Shared dotfiles
│       └── home-manager.nix # Shared home-manager config
├── overlays/                # Nix package overlays
├── flake.nix                # Flake definition and inputs
└── flake.lock               # Locked dependency versions
```

## Installation

### Option 1: Lix Installer (Recommended)

[Lix](https://lix.systems/) is a Nix fork with improved error messages and better defaults. It includes an uninstaller, making it easier to revert if you decide Nix isn't for you.

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix | sh -s -- install
```

After installation, follow the on-screen instructions to configure your shell.

**To uninstall Lix/Nix later:**
```bash
/nix/nix-installer uninstall
```

### Option 2: Official Nix Installer

The official installer works but is harder to uninstall cleanly:

```bash
curl -L https://nixos.org/nix/install | sh
```

You'll need to manually enable flakes by adding to `~/.config/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

### Setting Up This Configuration

This configuration is based on [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config), which provides step-by-step instructions for macOS setup.

1. **Clone this repository:**
   ```bash
   git clone https://github.com/natea/nixos-config.git
   cd nixos-config
   ```

2. **Make apps executable:**
   ```bash
   find apps/$(uname -m | sed 's/arm64/aarch64/')-darwin -type f \( -name apply -o -name build -o -name build-switch -o -name create-keys -o -name copy-keys -o -name check-keys -o -name rollback \) -exec chmod +x {} \;
   ```

3. **Apply your current user info:**
   ```bash
   nix run .#apply
   ```
   This will prompt you for your username, name, and email, then update the configuration files automatically.

4. **Build and switch to new configuration:**
   ```bash
   nix run .#build-switch
   ```

5. **Run post-install setup scripts:**
   ```bash
   # Configure DevPod to work with Nix-managed SSH config
   ~/.local/bin/setup-devpod

   # Install npm packages not available in nixpkgs
   ~/.local/bin/bootstrap-npm-packages
   ```

### Uninstalling Nix Completely

If you installed with Lix:
```bash
/nix/nix-installer uninstall
```

If you installed with the official installer, see the [Nix manual uninstall instructions](https://nixos.org/manual/nix/stable/installation/uninstall.html). The process involves:
1. Removing the Nix store (`/nix`)
2. Removing Nix configuration files
3. Removing shell profile modifications
4. Removing the `nixbld` users and group (macOS)

## Building and Applying

```bash
# Build the configuration (without applying)
nix run .#build

# Build and switch to new configuration
nix run .#build-switch

# Apply changes (alias for build-switch)
nix run .#apply

# Rollback to previous generation
nix run .#rollback

# Clean old generations
nix run .#clean
```

## Adding Software

### Decision Tree: Where to Add Software

```
Is it a GUI application for macOS?
├── Yes → Is it on the Mac App Store?
│         ├── Yes → Add to masApps in modules/darwin/home-manager.nix
│         └── No  → Add to modules/darwin/casks.nix
└── No  → Is it a CLI tool or library?
          ├── Yes → Is it macOS-specific?
          │         ├── Yes → Add to modules/darwin/packages.nix
          │         └── No  → Add to modules/shared/packages.nix
          └── No  → Consider if it's actually needed
```

### 1. Homebrew Casks (macOS GUI Apps)

For GUI applications distributed outside the Mac App Store (`.dmg`, `.app` files).

**File:** `modules/darwin/casks.nix`

```nix
[
  "visual-studio-code"
  "discord"
  "spotify"
  # Add your cask here
]
```

**Finding cask names:**
```bash
brew search <app-name>
```

### 2. Mac App Store Apps

For apps from the Mac App Store.

**File:** `modules/darwin/home-manager.nix` (in the `masApps` section)

```nix
masApps = {
  "App Name" = 123456789;  # App Store ID
};
```

**Finding App Store IDs:**
```bash
nix shell nixpkgs#mas
mas search "<app name>"
```

### 3. Nix Packages (CLI Tools, Libraries, Fonts)

For command-line tools, development utilities, fonts, and libraries.

**Cross-platform packages:** `modules/shared/packages.nix`
```nix
with pkgs; [
  git
  ripgrep
  nodejs
  # Add your package here
]
```

**macOS-only packages:** `modules/darwin/packages.nix`
```nix
shared-packages ++ [
  dockutil
  # Add macOS-specific package here
]
```

**Finding Nix packages:**
```bash
nix search nixpkgs <package-name>
```

Or browse https://search.nixos.org/packages

### 4. Dotfiles and Configuration Files

For configuration files managed in your home directory.

**Shared dotfiles:** `modules/shared/files.nix`
**macOS-specific dotfiles:** `modules/darwin/files.nix`

```nix
{
  ".config/myapp/config.yml".source = ./myapp-config.yml;

  ".local/bin/myscript" = {
    executable = true;
    text = ''
      #!/bin/bash
      echo "Hello"
    '';
  };
}
```

## Examples

### Adding a New GUI App (Homebrew Cask)

1. Find the cask name:
   ```bash
   brew search slack
   ```

2. Add to `modules/darwin/casks.nix`:
   ```nix
   "slack"
   ```

3. Rebuild:
   ```bash
   nix run .#build-switch
   ```

### Adding a Mac App Store App

1. Find the app ID:
   ```bash
   nix shell nixpkgs#mas
   mas search "Xcode"
   ```

2. Add to `modules/darwin/home-manager.nix`:
   ```nix
   masApps = {
     "Xcode" = 497799835;
   };
   ```

3. Rebuild:
   ```bash
   nix run .#build-switch
   ```

### Adding a CLI Tool

1. Search for the package:
   ```bash
   nix search nixpkgs ripgrep
   ```

2. Add to `modules/shared/packages.nix`:
   ```nix
   ripgrep
   ```

3. Rebuild:
   ```bash
   nix run .#build-switch
   ```

## Secrets Management

This configuration uses [agenix](https://github.com/ryantm/agenix) for secret management. Secrets are stored in a separate private repository to keep them out of your public dotfiles.

### Setting Up Your Secrets Repository

1. **Create a private GitHub repository** for your secrets (e.g., `yourusername/nix-secrets`)

   Use [dustinlyons/nix-secrets-example](https://github.com/dustinlyons/nix-secrets-example) as a template.

2. **During `nix run .#apply`**, you'll be prompted for your secrets repository path (e.g., `yourusername/nix-secrets`)

3. **Structure of the secrets repository:**
   ```
   nix-secrets/
   ├── secrets.nix          # Defines which keys can decrypt each secret
   ├── github-ssh-key.age   # Encrypted GitHub SSH private key
   └── ...                  # Other encrypted secrets
   ```

4. **The `secrets.nix` file** maps secrets to the public keys that can decrypt them:
   ```nix
   let
     your_key = "ssh-ed25519 AAAA... you@machine";
   in
   {
     "github-ssh-key.age".publicKeys = [ your_key ];
   }
   ```

### Adding a New Secret

1. Define the secret in your nix-secrets repo's `secrets.nix`:
   ```nix
   {
     "mysecret.age".publicKeys = [ your-ssh-public-key ];
   }
   ```

2. Create the encrypted secret using age:
   ```bash
   cd ~/nix-secrets
   age -r "ssh-ed25519 AAAA..." -o mysecret.age < /path/to/plaintext-secret
   ```

3. Reference in this configuration (e.g., `modules/darwin/secrets.nix`):
   ```nix
   age.secrets.mysecret = {
     file = "${secrets}/mysecret.age";
     path = "/Users/${user}/.config/myapp/secret";
   };
   ```

## Updating

### Update All Flake Inputs

```bash
nix flake update
```

### Update Specific Input

```bash
nix flake update nixpkgs
nix flake update home-manager
```

## Troubleshooting

### Build Errors

```bash
# Show full error trace
nix run .#build -- --show-trace

# Or build directly with trace
nix build .#darwinConfigurations.aarch64-darwin.system --show-trace
```

### Rollback

If something goes wrong after switching:
```bash
nix run .#rollback
```

### Clean Up Old Generations

```bash
# Remove old generations
nix run .#clean

# Manual garbage collection
nix-collect-garbage -d
```

### Common Issues

- **Homebrew cask not found:** Check the exact cask name with `brew search`
- **Package not found:** Search on https://search.nixos.org/packages
- **Permission errors:** Ensure you have admin rights on macOS
- **Mac App Store errors:** Sign in to the App Store first

## DevPod and Container Development

This configuration includes [DevPod](https://devpod.sh/) for development containers, with [Colima](https://github.com/abiosoft/colima) as a lightweight Docker Desktop alternative.

### Initial Setup

After installing the Nix configuration, run the DevPod setup script:

```bash
~/.local/bin/setup-devpod
```

This script:
1. Creates a writable `~/.ssh/config_external` file (since the main SSH config is Nix-managed and read-only)
2. Configures DevPod to write its SSH entries to this file
3. The main `~/.ssh/config` includes `config_external`, so everything works seamlessly

### Using Colima Instead of Docker Desktop

Colima provides a lighter-weight Docker runtime. To use it:

```bash
# Start Colima (creates a Linux VM with Docker)
colima start

# Verify Docker is working
docker ps

# Stop when done
colima stop
```

DevPod will automatically use whichever Docker runtime is available. No special configuration needed.

### Why This Setup?

The `~/.ssh/config` file is managed by home-manager (Nix) and is read-only. DevPod needs to write SSH configuration for each workspace it creates. The solution:
- Main SSH config (`~/.ssh/config`) includes `~/.ssh/config_external`
- DevPod writes to `config_external` (writable, not Nix-managed)
- Both files are read by SSH, giving you the best of both worlds

## Resources

### Official Documentation
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Package Search](https://search.nixos.org/packages)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [Homebrew Cask Search](https://formulae.brew.sh/cask/)

### Installation & Setup
- [Lix Installer](https://lix.systems/install/) - Recommended Nix installer with easy uninstall
- [nix-darwin](https://github.com/nix-darwin/nix-darwin) - NixOS-style configuration for macOS
- [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config) - Base configuration this repo is derived from

### Learning Nix
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Step-by-step Nix tutorial
- [nix.dev](https://nix.dev/) - Official Nix learning resources
- [Zero to Nix](https://zero-to-nix.com/) - Beginner-friendly Nix introduction

## Manual Configuration

If you prefer to configure user settings manually instead of using `nix run .#apply`, edit these files:

1. **`flake.nix`** - Change `user = "natea"` to your macOS username
   (This should match your home folder name, e.g., `/Users/yourusername`)

2. **`modules/shared/home-manager.nix`** - Update the git configuration:
   ```nix
   programs.git = {
     userName = "Your Name";
     userEmail = "your.email@example.com";
   };
   ```
