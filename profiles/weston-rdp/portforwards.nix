# from https://nixos.wiki/wiki/Wireguard
{ config, pkgs, ... }:
{
  # enable NAT
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.conf.default.forwarding" = 1;
    "net.ipv4.conf.eth0.route_localnet" = 1;
  };
  networking = {
    nat = {
      enable = true;
      externalInterface = "ens3";
      internalInterfaces = [ "wg0" ];
      forwardPorts = [
        {
          destination = "10.100.0.2:3423";
          proto = "udp";
          sourcePort = 3423;
        }
        {
          destination = "10.100.0.2:3423";
          proto = "tcp";
          sourcePort = 3423;
        }
      ];
    };
    firewall = {
      allowedUDPPorts = [ 3423 ];
      allowedTCPPorts = [ 3423 ];
    };
  };
}
