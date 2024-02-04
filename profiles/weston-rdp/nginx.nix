{ config, lib, pkgs, ... }:

{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "rdp.nanashi0x74.dev" = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    certs = {
      "rdp.nanashi0x74.dev" = {
        postRun = "systemctl reload nginx.service";
        email = "rian.lindenberger@gmail.com";
      };
    };
  };
  networking.firewall = {
    allowedUDPPorts = [ 3423 ];
    allowedTCPPorts = [ 3423 ];
  };
}
