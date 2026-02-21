Use this to update Nix:

sudo /run/current-system/sw/bin/darwin-rebuild switch --flake /Users/backlit/nixos-config#aarch64-darwin

sudo nix run nix-darwin -- switch --flake .#aarch64-darwin