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
    emacs-overlay.url  = "github:nix-community/emacs-overlay";
    cachix-decl = {
      url = "github:jonascarpay/declarative-cachix";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, self, agenix, cachix-decl, ... }:
    let
      inherit (lib.my) mapModulesRec mapHosts;
      system = "x86_64-linux";
      mkPkgs = pkgs: extraOverlays:
        import pkgs {
          inherit system;
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
      nixosConfigurations = mapHosts ./machines { };
    };
}
