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
      virtualHosts."nanashi0x74.dev".locations."/feedreader" = {
        root = "/var/lib/selfoss/";
        extraConfig = ''
          location ~* \.php/?$ {
              fastcgi_split_path_info ^/feedreader/(.+\.php)(/.+)$;
              include ${pkgs.nginx}/conf/fastcgi_params;
              include ${pkgs.nginx}/conf/fastcgi.conf;
              fastcgi_pass unix:${config.services.phpfpm.pools.${config.services.selfoss.pool}.socket};
          }
        '';
      };
    };
  };
}
