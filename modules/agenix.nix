# modules/agenix.nix -- encrypt secrets in nix store

{ options, config, inputs, lib, pkgs, ... }:

let
  inherit (builtins) pathExists filter removeAttrs;
  inherit (lib) mapAttrs' nameValuePair removeSuffix mkDefault;
  inherit (inputs) agenix;
  secretsDir = "${toString ../machines}/${config.networking.hostName}/secrets";
  secretsFile = "${secretsDir}/secrets.nix";
in
{
  imports = [ agenix.nixosModules.age ];
  environment.systemPackages = [ agenix.packages.x86_64-linux.default ];

  age = {
    secrets =
      if pathExists secretsFile then
        mapAttrs'
          (n: v:
            nameValuePair
              (removeSuffix ".age" n)
              (removeAttrs v [ "publicKeys" ]))
          (import secretsFile)
      else
        { };
    identityPaths = options.age.identityPaths.default ++ (filter pathExists [
      "${config.user.home}/.ssh/id_ed25519"
      "${config.user.home}/.ssh/id_rsa"
    ]);
  };
}
