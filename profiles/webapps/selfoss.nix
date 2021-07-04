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
        root = "/var/lib/selfoss";
        index = "index.php";
        extraConfig = let fpm = config.services.phpfpm.pools.${config.services.selfoss.pool}; in ''
          fastcgi_split_path_info ^(.+\.php)(feedreader/.+)$;
          fastcgi_pass unix:${fpm.socket};
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        '';
      };
    };
  };


}
