{ config, pkgs, ... }: {
  imports = [
    ../../hardware-configuration.nix
    ../../profiles/defaults-servers.nix
    ../../profiles/ssh-decrypt.nix
    ../../profiles/openssh-config.nix
    ../../profiles/wireguard/wg-server.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  boot = {
    kernelParams = [ "ip=51.15.10.88::51.15.10.1:255.255.255.255:matador" ];
    initrd = {
      luks.devices = {
        "cryptroot" = {
          device = "/dev/disk/by-uuid/41dc39e2-5122-4b47-9079-cddcc299af58";
          preLVM = true;
        };
      };
    };
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  networking.usePredictableInterfaceNames = false;
  networking.useDHCP = false;
  networking.interfaces.enp0s20.useDHCP = true;
  networking.interfaces.eth0.useDHCP = true;
  networking.nameservers = [ "62.210.16.6" "62.210.16.7" "1.1.1.1" ];
  networking.hostName = "matador";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "Europe/Amsterdam";

  environment.systemPackages = with pkgs; [ wget neovim git ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      7474
      7475 # SSH
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}

