# from https://nixos.wiki/wiki/Wireguard
{ config, pkgs, ... }:
{
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
