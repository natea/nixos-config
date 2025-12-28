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
