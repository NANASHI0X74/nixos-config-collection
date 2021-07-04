{ config, lib, pkgs, ... }:

{
  services = {
    selfoss = {
      enable = true;
      database = {
        type = "pgsql";
        password = "notsosecret";
      };
    };
    nginx = {
      enable = true;
      virtualHosts."nanashi0x74.dev".locations.feedreader.extraConfig = let fpm = config.services.phpfpm.pools.${config.services.selfoss.pool}; in ''
         fastcgi_pass unix:${fpm.socket};
      '';
    };
  };


}
