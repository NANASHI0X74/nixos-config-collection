{config, pkgs, ... }:
{
  services = {
    postgresql = {
      enable = true;
    };
    matrix-synapse = {
      enable = true;
      server_name = "nanashi0x74.dev";
      # public_baseurl = "https://matrix.nanashi0x74.tech";
      tls_certificate_path = "/etc/matrix-synapse/certs/fullchain.pem";
      tls_private_key_path = "/etc/matrix-synapse/certs/key.pem";
      registration_shared_secret = "notasecret";
      database_type = "psycopg2";
      database_args = {
        database = "matrix-synapse";
      };
      app_service_config_files = [
        "/var/lib/matrix-synapse/telegram-registration.yaml"
      ];
      listeners = [
        { #federation
          bind_address = "";
          port = 8448;
          resources = [
            { compress = true; names = [ "client" "webclient" ]; }
            { compress = false; names = [ "federation" ]; }
          ];
          tls = true;
          type = "http";
          x_forwarded = false;
        }
        { # client
          bind_address = "127.0.0.1";
          port = 8008;
          resources = [
            { compress = true; names = [ "client" "webclient" ]; }
          ];
          tls = false;
          type = "http";
          x_forwarded = true;
        }
      ];
      extraConfig = ''
        max_upload_size: "100M"
      '';
    };
    # web client proxy and setup certs
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "nanashi0x74.dev" = {
          locations = {
            "= /.well-known/matrix/server".extraConfig =
              let
                server = { "m.server" = "matrix.nanashi0x74.dev:8448"; };
              in ''
                add_header Content-Type application/json;
                return 200 '${builtins.toJSON server}';
              '';

            "= /.well-known/matrix/client".extraConfig =
              let
                client = {
                  "m.homeserver" =  { "base_url" = "https://matrix.nanashi0x74.dev"; };
                  "m.identity_server" =  { "base_url" = "https://vector.im"; };
                };
                # ACAO required to allow riot-web on any URL to request this json file
              in ''
                add_header Content-Type application/json;
                add_header Access-Control-Allow-Origin *;
                return 200 '${builtins.toJSON client}';
              '';
          };
          enableACME = true;
          forceSSL = true;
        };
        "matrix.nanashi0x74.dev" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:8008";
            };
          };
        };
      };
    };
  };

  security.acme.certs = {
    "nanashi0x74.dev" = {
      postRun = "systemctl reload nginx.service; systemctl restart matrix-synapse.service";
      email = "rian.lindenberger@gmail.com";
    };
    "matrix.nanashi0x74.dev" = {
      postRun = ''
                    cp /var/lib/acme/matrix.nanashi0x74.dev/key.pem /etc/matrix-synapse/certs && chown matrix-synapse:matrix-synapse /etc/matrix-synapse/certs/key.pem;;
                    cp /var/lib/acme/matrix.nanashi0x74.dev/fullchain.pem /etc/matrix-synapse/certs && chown matrix-synapse:matrix-synapse /etc/matrix-synapse/certs/fullchain.pem;;
                    systemctl reload nginx.service;
                    systemctl restart matrix-synapse.service;
      '';
      email = "rian.lindenberger@gmail.com";
    };
  };
  security.acme.acceptTerms = true;

  services.mautrix-telegram = {
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
}
