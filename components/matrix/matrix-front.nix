{config, pkgs, ...}:
{
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
              # use 443 instead of the default 8448 port to unite
              # the client-server and server-server port for simplicity
              server = { "m.server" = "matrix.nanashi0x74.dev:443"; };
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
    };
  };
  security.acme.certs = {
    "nanashi0x74.dev" = {
      group = "matrix-synapse";
      allowKeysForGroup = true;
      postRun = "systemctl reload nginx.service; systemctl restart matrix-synapse.service";
      email = "rian.lindenberger@gmail.com";
    };
  };
  security.acme.acceptTerms = true;
};
