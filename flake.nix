# To update flake.lock run:
# sudo nix flake update --recreate-lock-file --commit-lock-file /etc/nixos

{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.home-manager.url = "github:nix-community/home-manager/master";
  inputs.home-manager.inputs.nixpkgs.follows = "/nixpkgs";

  outputs = inputs: {

    nixosConfigurations.quomp = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # Things in this set are passed to modules and accessible
      # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager

        ({ pkgs, ... }: {
          nix = {
            extraOptions = "experimental-features = nix-command flakes";
            package = pkgs.nixFlakes;
            registry.nixpkgs.flake = inputs.nixpkgs;
            autoOptimiseStore = true;
          };
          home-manager.useGlobalPkgs = true;
        })

        ./machines/quomp/configuration.nix
      ];
    };

  };
}
