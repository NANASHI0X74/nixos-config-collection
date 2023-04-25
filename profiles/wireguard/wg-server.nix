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
          destination = "10.100.0.2:80";
          proto = "tcp";
          sourcePort = 80;
        }
        {
          destination = "10.100.0.2:443";
          proto = "tcp";
          sourcePort = 443;
        }
        {
          destination = "10.100.0.2:7475";
          proto = "tcp";
          sourcePort = 7476;
        }
        {
          destination = "10.100.0.2:8448";
          proto = "tcp";
          sourcePort = 8448;
        }
      ];
    };
    firewall = {
      allowedUDPPorts = [ 51820 ];
      allowedTCPPorts = [ 8448 443 80 ];
    };
    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.1/24" ];
        listenPort = 51820;
        privateKeyFile = "/root/wireguard-keys/private";
        peers = [{
          publicKey = "d81iwtv/dubG3LzQHOAi/U4uqACISnlVj9fI9tcVunQ=";
          allowedIPs = [ "10.100.0.2/32" ];
        }];

        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -d 10.100.0.0/24 -o wg0 -j MASQUERADE
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -d 10.100.0.0/24 -o wg0 -j MASQUERADE
        '';
      };
    };
  };
}
