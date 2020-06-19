{ config, pkgs, ... }:
{
	services.openssh = {
		enable = true;
		ports = [ 7475 ];
	};
	users.users.root.openssh.authorizedKeys.keys = import ../resources/ssh-pubkeys.nix;
}
