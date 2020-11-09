{config, pkgs, ... }:
{
  security.acme.email = "rian.lindenberger@gmail.com";
  security.acme.acceptTerms = true;
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."git.nanashi0x74.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
    };
  };

  services.gitlab = {
    enable = true;
    databasePasswordFile = "/var/keys/gitlab/db_password";
    initialRootPasswordFile = "/var/keys/gitlab/root_password";
    https = true;
    host = "git.nanashi0x74.dev";
    port = 443;
    user = "gitlab";
    group = "gitlab";
    smtp = {
      enable = true;
      address = "localhost";
      port = 25;
    };
    secrets = {
      dbFile = "/var/keys/gitlab/db";
      secretFile = "/var/keys/gitlab/secret";
      otpFile = "/var/keys/gitlab/otp";
      jwsFile = "/var/keys/gitlab/jws";
    };
    extraConfig = {
      gitlab_shell = {
        ssh_port = 7476;
      };
    };
    # extraConfig = {
    #   gitlab = {
    #     email_from = "gitlab-no-reply@example.com";
    #     email_display_name = "Example GitLab";
    #     email_reply_to = "gitlab-no-reply@example.com";
    #     default_projects_features = { builds = false; };
    #   };
    # };
  };
}
