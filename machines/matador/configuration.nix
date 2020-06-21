{ config, pkgs, ... }:
{
  imports =
    [
      ../../hardware-configuration.nix
      ../../components/defaults-servers.nix
      ../../components/ssh-decrypt.nix
      ../../components/openssh-config.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  boot = {
    kernelParams = [ "ip=51.15.10.88::51.15.10.1:255.255.255.255:matador" ];
    initrd = {
      luks.devices = [{
        name = "cryptroot";
  device = "/dev/disk/by-uuid/41dc39e2-5122-4b47-9079-cddcc299af58";
  preLVM = true;
      }];
      };
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  networking.useDHCP = false;
  networking.interfaces.enp0s20.useDHCP = true;
  networking.nameservers = [ "62.210.16.6" "62.210.16.7" "1.1.1.1" ];
  networking.hostName = "matador";

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Amsterdam";

  environment.systemPackages = with pkgs; [
    wget neovim git
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  services = {
    postgresql.enable = true;
    matrix-synapse = {
      enable = true;
      server_name = "matrix.nanashi0x74.tech";
      public_baseurl = "https://matrix.nanashi0x74.tech";
      tls_certificate_path = "/var/lib/acme/matrix.nanashi0x74.tech/fullchain.pem";
      tls_private_key_path = "/var/lib/acme/matrix.nanashi0x74.tech/key.pem";
      registration_shared_secret = "notasecret"; 
      database_type = "psycopg2";
      database_args = {
        database = "matrix-synapse";
      };
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
      virtualHosts = {
        "matrix.nanashi0x74.tech" = {
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

# share certs with matrix-synapse and restart on renewal
  security.acme.certs = {
    "matrix.nanashi0x74.tech" = {
      group = "matrix-synapse";
      allowKeysForGroup = true;
      postRun = "systemctl reload nginx.service; systemctl restart matrix-synapse.service";
     };
   };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      7474 7475    # SSH
      8448  # Matrix federation
      80    # http
      443   # https
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

