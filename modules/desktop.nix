{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.desktop;
in
{
  options.modules.desktop = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; with libsForQt5;[
      gnome.gnome-tweaks
      gnomeExtensions.appindicator
      kwallet
      kwallet-pam
    ];
    services = {
      gnome.gnome-keyring.enable = lib.mkForce false;
      udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
      pipewire = {
        audio.enable = true;
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
        xkbOptions = "eurosign:e,grp:caps_switch";
        displayManager.gdm.enable = true;
        desktopManager = {
          # plasma5.enable = true;
          gnome.enable = true;
        };
        # libinput = {
        #   enable = true;
        #   touchpad.clickMethod = "clickfinger";
        # };
      };
    };

    # following are needed because of conflicting configs in different enabled desktop envs
    hardware.pulseaudio = {
      enable = false; # pipewire is used instead, needed because gnome enables it by default
      zeroconf.discovery.enable = true;
    };
    programs.ssh.askPassword = "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";

    security = {
      pam.services.login.enableKwallet = true;
      rtkit.enable = true;
    };

  };
}
