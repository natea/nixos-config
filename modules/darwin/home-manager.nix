{ config, pkgs, lib, home-manager, ... }:

let
  user = "backlit";
  # Define the content of your file as a derivation
  myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
    #!/bin/sh
    emacsclient -c -n &
  '';
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
in
{
  imports = [
   ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    brews = [
      "gromgit/fuse/sshfs-mac"  # SSHFS for mounting remote filesystems
    ];
    # onActivation.cleanup = "uninstall";

    # Note: Third-party taps (like spotinst/tap) require mutableTaps = true in flake.nix
    # Since we use mutableTaps = false, install them manually: brew install spotinst/tap/spotctl

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)

    masApps = {
      # "wireguard" = 1451685025;
      "Day One" = 1055511498;
      "Perplexity" = 6714467650;
      "Save to Reader" = 1640236961; # for Readwise
      "Copilot" = 1447330651;
      "Code Piper Lite" = 1669959741;
      "Microsoft Word" = 462054704;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Excel" = 462058435;
      "Save to Raindrop.io" = 1549370672;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.${user} = { pkgs, config, lib, ... }:
      let
        # Import files with home-manager's config (has config.lib.file)
        hmAdditionalFiles = import ./files.nix { inherit user pkgs; config = config; };
      in {
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          hmAdditionalFiles
          { "emacs-launcher.command".source = myEmacsLauncher; }
        ];

        # Add additional bin directories to PATH
        sessionPath = [
          "$HOME/.cargo/bin"
          "$HOME/.local/bin"
        ];

        # Personal AI Infrastructure directory
        sessionVariables = {
          PAI_DIR = "$HOME/.config/pai";
          DOCKER_HOST = "unix://$HOME/.colima/default/docker.sock";
        };

        stateVersion = "23.11";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local = {
    dock = {
      enable = true;
      username = user;
      entries = [
        { path = "/Applications/Safari.app/"; }
        { path = "/System/Applications/Messages.app/"; }
        { path = "/System/Applications/Notes.app/"; }
        { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
        { path = "/System/Applications/Music.app/"; }
        { path = "/System/Applications/Photos.app/"; }
        { path = "/System/Applications/Photo Booth.app/"; }
        { path = "/System/Applications/System Settings.app/"; }
        {
          path = toString myEmacsLauncher;
          section = "others";
        }
        {
          path = "${config.users.users.${user}.home}/Downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };
}
