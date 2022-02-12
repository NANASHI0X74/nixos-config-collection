{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.dev.tmux;
  # TODO: ideally this should be a seperate package
  yank = pkgs.writeShellScriptBin "yank" (builtins.readFile ../../bin/tmux/yank.sh);
  renew_env = pkgs.writeShellScriptBin "renew_env" (builtins.readFile ../../bin/tmux/renew_env.sh);
in
{
  options.modules.dev.tmux.enable = mkBoolOpt false;
  config = mkIf cfg.enable {
    environment = {
      etc = {
        "tmux.conf".source = ../../non-nix/tmux/tmux.conf;
        "tmux.remote.conf".source = ../../non-nix/tmux/tmux.remote.conf;
      };
      systemPackages = [ pkgs.tmux yank renew_env ];
    };
  };
}
