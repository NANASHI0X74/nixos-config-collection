
{ config, pkgs, ... }:
{
	boot.initrd = {
		network.enable = true;
		network.ssh = {
			enable = true;
			authorizedKeys = import ../resources/ssh-pubkeys.nix;

			# need to be created beforehand
			# nix-shell -p dropbear --command "dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key"
			hostDSSKey = /etc/dropbear/dropbear_dss_host_key;
			# nix-shell -p dropbear --command "dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key"
			hostECDSAKey = /etc/dropbear/dropbear_ecdsa_host_key;
			# nix-shell -p dropbear --command "dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key"
			hostRSAKey = /etc/dropbear/dropbear_rsa_host_key;
			
			port = 7474;
		};
	};
}
