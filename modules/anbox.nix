{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.anbox;
in
{
  options.modules.anbox = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    virtualization.anbox.enable = true;
  };
}
