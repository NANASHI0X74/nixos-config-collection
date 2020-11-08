# from https://nixos.wiki/wiki/Wireguard
{config, pkgs, ...}:
{
  imports = [ ./restart-after-upgrade.nix ];
  networking.firewall.allowedUDPPorts = [ 58531 ];
  # Enable Wireguard
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "10.100.0.2/24" ];
      listenPort = 58531;

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/root/wireguard-keys/private";

      peers = [
        # For a client configuration, one peer entry for the server will suffice.
        {
          # Public key of the server (not a file path).
          publicKey = "j/WWETRqOr+CwXlqJaAHDcT9pHF/0DfyMQBeUoRGXHY=";

          # Forward all the traffic via VPN.
          allowedIPs = [ "10.100.0.1" ];
          # Or forward only particular subnets
          #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];

          # Set this to the server IP and port.
          endpoint = "51.15.10.88:51820";

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
