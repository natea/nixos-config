{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  dockutil
  jellyfin        # Media server
  # immich        # Self-hosted photo/video backup (disabled: nixpkgs build failing on sharp/pnpm)
]
