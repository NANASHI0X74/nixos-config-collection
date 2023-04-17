{ config, pkgs, ... }: {
  imports = [
    ../../hardware-configuration.nix
    ../../profiles/defaults-servers.nix
    ../../profiles/openssh-config.nix
    ../../profiles/wireguard/wg-server.nix
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_GB.utf8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [ neovim git ];

  networking = {
    hostname = "llama";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        7474
        7475 # SSH
      ];
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11"; # Did you read the comment?
}
