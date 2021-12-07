{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.dev.tmux;
in
{
  options.modules.dev.git.enable = mkBoolOpt false;
  config = mkIf cfg.enable {
    environment = {
      etc = {
       "tmux.conf".source = ../../non-nix/tmux/tmux.conf;
       "tmux.remote.conf".source = ../../non-nix/tmux/tmux.remote.conf;
      };
      systemPackages = [ pkgs.tmux pkgs.writeShellScriptBin "yank.sh" builtins.readFile ../../bin/tmux/yank.sh];
    };
  };
}
