{ config, lib, pkgs, ... }:

{
  modules.waydroid.enable = true;
  environment.systemPackages = [ pkgs.sway ];
}
