{ config, pkgs, ... }: {
  boot.initrd = {
    network.enable = true;
    network.ssh = {
      enable = true;
      authorizedKeys = (import ../resources/ssh-pubkeys.nix).personal_keys;

      # need to be created beforehand using ssh-keygen
      hostKeys = [
        /etc/openssh/dss_host_key
        /etc/openssh/ecdsa_host_key
        /etc/openssh/rsa_host_key
      ];

      port = 7474;
    };
  };
}
