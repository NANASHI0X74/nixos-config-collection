{ config, lib, pkgs, ... }:

{
  services = {
    matrix-synapse.settings.app_service_config_files = [
          "/var/lib/matrix-synapse/telegram-registration.yaml"
        ];
    mautrix-telegram = {
      enable = true;
      environmentFile = /etc/secrets/mautrix-telegram.env; # file containing the appservice and telegram tokens
      # The appservice is pre-configured to use SQLite by default. It's also possible to use PostgreSQL.
      settings = {
        homeserver = {
          address = "http://localhost:8008";
          domain = "nanashi0x74.dev";
        };
        appservice = {
          provisioning.enabled = false;
          id = "@telegrambot:nanashi0x74.dev";
          public = {
            enabled = true;
            prefix = "/public";
            external = "http://matrix.nanashi0x74.dev/public";
          };
        };
        bridge = {
          relaybot.authless_portals = false;
          permissions = {
            "@donjoe:nanashi0x74.dev" = "admin";
          };
        };
      };
    };
  };
}
