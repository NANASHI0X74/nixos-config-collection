{ config, lib, pkgs, ... }:

{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "nanashi0x74.dev" = {
        locations = { "/staticstuff/" = { proxyPass = ""; }; };
        enableACME = true;
        forceSSL = true;
      };
    };
  };
}
