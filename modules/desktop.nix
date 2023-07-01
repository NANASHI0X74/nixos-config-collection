{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.editors.emacs;
  configDir = config.dotfiles.configDir;
in
{
  options.modules.desktop = {
    enable = mkBoolOpt false;
  };
  config = {
    services = {
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
      };
      xserver = {
        enable = true;
        layout = "gb,de";
        # xkbOptions = "eurosign:e,grp:caps_switch";
        displayManager = {
          sddm.enable = true;
          defaultSession = "plasmawayland";
        };
        desktopManager = {
          plasma5.enable = true;
          gnome.enable = true;
        };
        # libinput = {
        #   enable = true;
        #   touchpad.clickMethod = "clickfinger";
        # };
      };
    };

    # following are needed because of conflicting configs in different enabled desktop envs
    hardware.pulseaudio.enable = false; # pulseaudio is used instead, needed because gnome enables it by default
    programs.seahorse.enable = false;
  };
}
