# from https://nixos.wiki/wiki/Wireguard
{config, pkgs, ...}:
{
  # enable NAT
  networking = {
    nat = {
      enable = true;
      externalInterface = "eth0";
      internalInterfaces = [ "wg0" ];
      forwardPorts = [
        {
          destination = "192.168.178.42:80";
          proto = "tcp";
          sourcePort = "80";
        }
        {
          destination = "192.168.178.42:443";
          proto = "tcp";
          sourcePort = "443";
        }
        {
          destination = "192.168.178.42:8008";
          proto = "tcp";
          sourcePort = "8008";
        }
        {
          destination = "192.168.178.42:8448";
          proto = "tcp";
          sourcePort = "8448";
        }
      ];
    };
      firewall = {
        allowedUDPPorts = [ 51820 ];
        allowedTCPPorts = [ 8448, 8008, 443, 80];
      };

      wireguard.interfaces = {
        # "wg0" is the network interface name. You can name the interface arbitrarily.
        wg0 = {
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          ips = [ "192.168.178.230/24" ];

          # The port that Wireguard listens to. Must be accessible by the client.
          listenPort = 51820;

          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
          # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
          postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        '';

          # This undoes the above command
          postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        '';

          # Path to the private key file.
          #
          # Note: The private key can also be included inline via the privateKey option,
          # but this makes the private key world-readable; thus, using privateKeyFile is
          # recommended.
          privateKeyFile = "/root/wireguard-keys/private";

          peers = [
            # List of allowed peers.
            { # Feel free to give a meaning full name
              # Public key of the peer (not a file path).
              publicKey = "d81iwtv/dubG3LzQHOAi/U4uqACISnlVj9fI9tcVunQ=";
              # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
              allowedIPs = [ "192.168.178.42/32" ];
            }
          ];
        };
    };
  };

}
