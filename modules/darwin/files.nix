{ user, config, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;
  xdg_configHome = "${homeDir}/.config";
  xdg_dataHome   = "${homeDir}/.local/share";
  xdg_stateHome  = "${homeDir}/.local/state";
in
{

  # DevPod CLI symlink
  ".local/bin/devpod" = {
    source = config.lib.file.mkOutOfStoreSymlink "/Applications/DevPod.app/Contents/MacOS/devpod-cli";
  };

  # DevPod setup script - configures DevPod to use config_external for SSH
  # Run once after DevPod is installed: ~/.local/bin/setup-devpod
  # This creates a writable ~/.ssh/config_external file (not Nix-managed)
  # and configures DevPod to use it instead of the read-only ~/.ssh/config
  ".local/bin/setup-devpod" = {
    executable = true;
    text = ''
      #!/bin/bash
      set -e

      DEVPOD_CLI="${homeDir}/.local/bin/devpod"
      SSH_CONFIG_EXTERNAL="${homeDir}/.ssh/config_external"

      if [[ ! -x "$DEVPOD_CLI" ]] && [[ ! -L "$DEVPOD_CLI" ]]; then
        echo "DevPod CLI not found at $DEVPOD_CLI"
        echo "Make sure DevPod.app is installed first."
        exit 1
      fi

      # Create writable config_external if it doesn't exist or is a symlink
      if [[ -L "$SSH_CONFIG_EXTERNAL" ]]; then
        echo "Removing Nix-managed symlink at $SSH_CONFIG_EXTERNAL..."
        rm "$SSH_CONFIG_EXTERNAL"
      fi

      if [[ ! -f "$SSH_CONFIG_EXTERNAL" ]]; then
        echo "Creating writable $SSH_CONFIG_EXTERNAL..."
        cat > "$SSH_CONFIG_EXTERNAL" << 'SSHEOF'
# This file is for SSH config entries managed by external tools (e.g., DevPod)
# It is included by the main ~/.ssh/config managed by home-manager
SSHEOF
        chmod 600 "$SSH_CONFIG_EXTERNAL"
      fi

      echo "Configuring DevPod to use ~/.ssh/config_external..."
      "$DEVPOD_CLI" context set-options -o SSH_CONFIG_PATH="$SSH_CONFIG_EXTERNAL"

      echo ""
      echo "Done! DevPod is configured to write SSH entries to ~/.ssh/config_external"
      echo "This file is included by the main ~/.ssh/config managed by Nix."
    '';
  };

  # Day One CLI symlink
  # Note: Day One must be installed and launched once before the CLI works
  ".local/bin/dayone" = {
    source = config.lib.file.mkOutOfStoreSymlink "/Applications/Day One.app/Contents/Resources/dayone2";
  };

  # Raycast script so that "Run Emacs" is available and uses Emacs daemon
  "${xdg_dataHome}/bin/emacsclient" = {
    executable = true;
    text = ''
      #!/bin/zsh
      #
      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title Run Emacs
      # @raycast.mode silent
      #
      # Optional parameters:
      # @raycast.packageName Emacs
      # @raycast.icon ${xdg_dataHome}/img/icons/Emacs.icns
      # @raycast.iconDark ${xdg_dataHome}/img/icons/Emacs.icns

      if [[ $1 = "-t" ]]; then
        # Terminal mode
        ${pkgs.emacs}/bin/emacsclient -t $@
      else
        # GUI mode
        ${pkgs.emacs}/bin/emacsclient -c -n $@
      fi
    '';
  };
}
