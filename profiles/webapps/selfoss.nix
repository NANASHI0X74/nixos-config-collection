{ config, lib, pkgs, ... }:

{
  services = {
    selfoss = {
      enable = true;
      database.type = "pgsql";
    };
    nginx = {
      enable = true;
      virtualHosts."nanashi0x74.dev".locations.feedreader.root = pkgs.selfoss;
    };
  };


}
