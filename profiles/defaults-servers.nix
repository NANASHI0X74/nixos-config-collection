{ config, pkgs, ... }:
{
  imports = [ ./defaults.nix ];
  services.fail2ban.enable = true;
}
