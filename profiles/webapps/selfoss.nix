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
      virtualHosts."nanashi0x74.dev".locations.feedreader.root = pkgs.selfoss;
    };
  };


}
