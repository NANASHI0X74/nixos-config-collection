{ options, config, lib, pkgs, ... }:

{

  # Install user packages to /etc/profiles instead. Necessary for
  # nixos-rebuild build-vm to work.
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;

    # I only need a subset of home-manager's capabilities. That is, access to
    # its home.file, home.xdg.configFile and home.xdg.dataFile so I can deploy
    # files easily to my $HOME, but 'home-manager.users.hlissner.home.file.*'
    # is much too long and harder to maintain, so I've made aliases in:
    #
    #   home.file        ->  home-manager.users.hlissner.home.file
    #   home.configFile  ->  home-manager.users.hlissner.home.xdg.configFile
    #   home.dataFile    ->  home-manager.users.hlissner.home.xdg.dataFile
    users.${config.user.name} = let inherit (lib) mkAliasDefinitions;
    in {
      home = {
        file = mkAliasDefinitions options.home.file;
        # Necessary for home-manager to work with flakes, otherwise it will
        # look for a nixpkgs channel.
        stateVersion = config.system.stateVersion;
      };
      xdg = {
        configFile = mkAliasDefinitions options.home.configFile;
        dataFile = mkAliasDefinitions options.home.dataFile;
      };
    };
  };
}
