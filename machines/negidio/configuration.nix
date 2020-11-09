# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../../components/wireguard/wg-client.nix
      ../../components/matrix/matrix-server.nix
      ../../hardware-configuration.nix
      ../../components/defaults-servers.nix
      ../../components/ssh-decrypt.nix
      ../../components/openssh-config.nix
      ../../components/gitlab.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only
  boot.initrd = {
    luks.devices = {
      "m2crypt" = {
        device = "/dev/disk/by-uuid/ceb75a70-c7d8-44a5-b91f-9cdd75d415e7";
        preLVM = true;
        allowDiscards = true;
      };
      "satacrypt" = {
        device = "/dev/disk/by-uuid/d089dd88-be21-45ea-a1e9-21958368359a";
        preLVM = true;
        allowDiscards = true;
      };
    };
  };

  # Supposedly better for the SSD.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  networking.hostName = "negidio"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;
  networking.wireless.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    neovim git tmux pciutils
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    7474 7475 # ssh
    8448 # matrix federation
    8008 # matrix client?
    80 # http
    443 # https
  ];
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

