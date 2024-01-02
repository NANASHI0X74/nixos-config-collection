{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.waydroid;
in
{
  options.modules.waydroid = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    virtualisation.waydroid.enable = true;
  };
}
