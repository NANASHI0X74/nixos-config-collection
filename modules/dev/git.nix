{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.dev.git;
in
{
  options.modules.dev.git.enable = mkBoolOpt false;
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.git ];
    home-manager.users.${config.user.name} = {
      programs.git = {
        enable = true;
        aliases = {
          co = "checkout";
        };
        userName = "nanashi0x74";
        userEmail = "rian.lindenberger@gmail.com";
      };
    };
  };
}
