# modules/agenix.nix -- encrypt secrets in nix store

{ options, config, inputs, lib, pkgs, ... }:

let
  inherit (builtins) pathExists filter;
  inherit (lib) mapAttrs' nameValuePair removeSuffix mkDefault;
  inherit (inputs) agenix;
  secretsDir = "${toString ../machines}/${config.networking.hostName}/secrets";
  secretsFile = "${secretsDir}/secrets.nix";
in {
  imports = [ agenix.nixosModules.age ];
  environment.systemPackages = [ agenix.defaultPackage.x86_64-linux ];

  age = {
    secrets = if pathExists secretsFile then
      mapAttrs' (n: _:
        nameValuePair (removeSuffix ".age" n) {
          file = "${secretsDir}/${n}";
          owner = mkDefault config.user.name;
        }) (import secretsFile)
    else
      { };
    sshKeyPaths = options.age.sshKeyPaths.default ++ (filter pathExists [
      "${config.user.home}/.ssh/id_ed25519"
      "${config.user.home}/.ssh/id_rsa"
    ]);
  };
}
