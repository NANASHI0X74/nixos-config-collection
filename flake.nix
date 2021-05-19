{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "/nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, self, agenix, ... }:
    let
      inherit (lib.my) mapModules mapModulesRec mapHosts;
      system = "x86_64-linux";
      mkPkgs = pkgs: extraOverlays:
        import pkgs {
          inherit system;
          config.allowUnfree = true; # forgive me Stallman senpai
          # overlays = extraOverlays ++ (lib.attrValues self.overlays);
        };
      pkgs = mkPkgs nixpkgs [ self.overlay ];
      lib = nixpkgs.lib.extend (self: super: {
        my = import ./lib {
          inherit pkgs inputs;
          lib = self;
        };
      });
    in {
      nixosModules = { common = import ./.; } // mapModulesRec ./modules import;
      # nixosConfigurations.quomp = inputs.nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   # Things in this set are passed to modules and accessible
      #   # in the top-level arguments (e.g. `{ pkgs, lib, inputs, ... }:`).
      #   specialArgs = { inherit inputs; };
      #   modules = [
      #     inputs.agenix.nixosModules.age
      #     inputs.home-manager.nixosModules.home-manager

      #     ({ pkgs, ... }: {
      #       nix = {
      #         extraOptions = "experimental-features = nix-command flakes";
      #         package = pkgs.nixFlakes;
      #         registry.nixpkgs.flake = inputs.nixpkgs;
      #         autoOptimiseStore = true;
      #       };
      #       home-manager.useGlobalPkgs = true;
      #     })

      #     ./machines/quomp/configuration.nix
      #   ];
      # };
      nixosConfigurations = mapHosts ./machines { };

    };
}
