{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.syncthing;
in
{
  options.modules.syncthing = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "${config.user.name}";
      dataDir = "${config.user.home}/Documents";
      configDir = "${config.user.home}/Documents/.config/syncthing";
    };
  };
}
