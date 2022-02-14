{ config, pkgs, ... }:
{
  networking.firewall.allowedUDPPorts = [ 58531 ];
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.2/24" ];
      listenPort = 58531;
      privateKeyFile = "/root/wireguard-keys/private";
      peers = [{
        publicKey = "j/WWETRqOr+CwXlqJaAHDcT9pHF/0DfyMQBeUoRGXHY=";
        allowedIPs = [ "10.100.0.0/24" ];
        endpoint = "51.15.10.88:51820";
        persistentKeepalive = 25;
      }];
    };
  };
}
