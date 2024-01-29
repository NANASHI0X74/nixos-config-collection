{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.syncthing;
in
{
  environment.systemPackages = [ pkgs.syncthing ];
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
    networking.firewall.allowedTCPPorts = [ 22000 ]; # tcp sync traffic
    networking.firewall.allowedUDPPorts = [
      22000 # udp sync traffic
      21027 # discovery broadcasts
    ];
  };
}
