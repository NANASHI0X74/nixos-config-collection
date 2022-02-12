{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.dev.git;
in
{
  options.modules.dev.direnv.enable = mkBoolOpt false;

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      config = {
        skip_dotenv = true;
      };
    };
  };
}
