{ config, pkgs, ... }:
{
  services = {
    matrix-synapse = {
      enable = true;
      settings = {
        server_name = "nanashi0x74.dev";
        tls_certificate_path = "/etc/matrix-synapse/certs/fullchain.pem";
        tls_private_key_path = "/etc/matrix-synapse/certs/key.pem";
        registration_shared_secret = "notasecret";

        database = {
          name = "psycopg2";
          args = {
            database = "matrix-synapse";
          };
        };

        max_upload_size = "100M";
        listeners = [
          {
            #federation
            bind_addresses = [ "" ];
            port = 8448;
            resources = [
              { compress = true; names = [ "client" ]; }
              { compress = false; names = [ "federation" ]; }
            ];
            tls = true;
            type = "http";
            x_forwarded = false;
          }
          {
            # client
            bind_addresses = [ "127.0.0.1" ];
            port = 8008;
            resources = [
              { compress = true; names = [ "client" ]; }
            ];
            tls = false;
            type = "http";
            x_forwarded = true;
          }
        ];
      };
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
              in
              ''
                add_header Content-Type application/json;
                return 200 '${builtins.toJSON server}';
              '';

            "= /.well-known/matrix/client".extraConfig =
              let
                client = {
                  "m.homeserver" = { "base_url" = "https://matrix.nanashi0x74.dev"; };
                  "m.identity_server" = { "base_url" = "https://vector.im"; };
                };
                # ACAO required to allow riot-web on any URL to request this json file
              in
              ''
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

  security.acme = {
    acceptTerms = true;
    certs = {
      "nanashi0x74.dev" = {
        postRun = "systemctl reload nginx.service; systemctl restart matrix-synapse.service";
        email = "rian.lindenberger@gmail.com";
      };
      "matrix.nanashi0x74.dev" = {
        postRun = ''
          cp /var/lib/acme/matrix.nanashi0x74.dev/key.pem /etc/matrix-synapse/certs && chown matrix-synapse:matrix-synapse /etc/matrix-synapse/certs/key.pem;
          cp /var/lib/acme/matrix.nanashi0x74.dev/fullchain.pem /etc/matrix-synapse/certs && chown matrix-synapse:matrix-synapse /etc/matrix-synapse/certs/fullchain.pem;
          systemctl reload nginx.service;
          systemctl restart matrix-synapse.service;
        '';
        email = "rian.lindenberger@gmail.com";
      };
    };
  };
}
