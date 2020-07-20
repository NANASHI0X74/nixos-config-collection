{config, pkgs, ...}:
{
	systemd.services.wireguard-restart-after-upgrade = {
		after = [ "nixos-upgrade.service" ];
		wants = [ "nixos-upgrade.service" ];
		script = 
		  ''
		    /nix/store/djgbl8rvjs2h3jmq65182yahchws8s35-iproute2-5.2.0/bin/ip link set wg0 down
		    /nix/store/djgbl8rvjs2h3jmq65182yahchws8s35-iproute2-5.2.0/bin/ip link set wg0 up
	          '';
	};
}
