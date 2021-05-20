{ config, options, lib, home-manager, ... }:

let
  inherit (lib)
    pathExists
    types
    elem
    mkAliasDefinitions
    ;
  inherit (lib.attrsets)
    mapAttrsToList
    mapAttrs
    ;
  inherit (lib.strings)
    concatMapStringsSep
    concatStringsSep
    ;
  inherit (lib.lists)
    findFirst
    isList
    ;
  inherit (lib.options) mkOption;
  inherit (lib.my) mkOpt mkOpt';
in
{
  options = with types; {
    user = mkOpt attrs {};

    dotfiles =
      {
        dir = mkOpt path (
          findFirst pathExists (toString ../.) [
            "${config.user.home}/.config/dotfiles"
            "/etc/dotfiles"
          ]
        );
        binDir = mkOpt path "${config.dotfiles.dir}/bin";
        configDir = mkOpt path "${config.dotfiles.dir}/config";
        modulesDir = mkOpt path "${config.dotfiles.dir}/modules";
        themesDir = mkOpt path "${config.dotfiles.modulesDir}/themes";
      };

    home = {
      file = mkOpt' attrs {} "Files to place directly in $HOME";
      configFile = mkOpt' attrs {} "Files to place in $XDG_CONFIG_HOME";
      dataFile = mkOpt' attrs {} "Files to place in $XDG_DATA_HOME";
    };

    env = mkOption {
      type = attrsOf (oneOf [ str path (listOf (either str path)) ]);
      apply = mapAttrs (
        n: v:
          if isList v then
            concatMapStringsSep ":" (x: toString x) v
          else
            (toString v)
      );
      default = {};
      description = "TODO";
    };
  };

  config = {
    user = let
      user = builtins.getEnv "USER";
      name = if elem user [ "" "root" ] then "nanashi" else user;
    in
      {
        inherit name;
        description = "The primary user account";
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        home = "/home/${name}";
        group = "users";
        uid = 1000;
      };

    users.users.${config.user.name} = mkAliasDefinitions options.user;

    nix = let
      users = [ "root" config.user.name ];
    in
      {
        trustedUsers = users;
        allowedUsers = users;
      };

    # must already begin with pre-existing PATH. Also, can't use binDir here,
    # because it contains a nix store path.
    env.PATH = [ "$DOTFILES_BIN" "$XDG_BIN_HOME" "$PATH" ];

    environment.extraInit = concatStringsSep "\n"
      (mapAttrsToList (n: v: ''export ${n}="${v}"'') config.env);
  };
}
