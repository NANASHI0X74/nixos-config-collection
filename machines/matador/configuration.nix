# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./components/ssh-decrypt.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only


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
  };

  networking.nameservers = [ "62.210.16.6" "62.210.16.7" "1.1.1.1" ];
  networking.hostName = "matador"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s20.useDHCP = true;

  users.users.root.openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCslUchy7sMNYNUg9a//cgl1pG1HPoPso62VriPtmDDZ956Q9AEVMDK8FU2KVb1ZN1VONdjt4zelQyb4l/cUfoS5HzEc/qry7Q538QgeK7LECW1dXbOioxUL7WcpVR07RJVofoD2mNlyyOGB62wusX9SYWUqDFgjWZj0g2fUzR2lsklRsEEM8ZFGLytmYpJ0FIeOSidn8XM+qHErTTTRrLjEDGTgkmtUFaTVzRobiGnkr5SyDx8uUWqagotoct62HOLb2n01JmJvLqCFbrBdUBgC+jSSwgygqZTGWPD5mxaH9tvBLhNt+7apNc19fNCio8JoxVUyqsBqa12hKeZPK6E4eoUPpK6HWk/LtGRUKYeO01aRa3uqK+VAKHSECss+TuVfcnhKbi8u+AJ9PnrVur7+tC9xlqAf+J154sVGZy6GPYD5zxtskTBqdB93BBko16eB9iKxgPw7uu/4tU1pY1ypRyxzkk4tjLlgX5/Wz0fOv/PXT9LnBYLUD/V2PdUmmc= rian@rian-ThinkPad-S3-Yoga-14"];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget neovim git matrix-synapse
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services = {
    openssh = { 
      enable = true;
      ports = [ 7475 ];
    };
    postgresql.enable = true;
    matrix-synapse = {
      enable = true;
      server_name = "matrix.nanashi0x74.tech";
      public_baseurl = "https://matrix.nanashi0x74.tech";
      # registration_shared_secret = "z2d0C0RtVAknZ6bEliL3PR2ZKdQ4nrxk1JYBBvVtADDpXMhz4eRRWQFQ3XdrQUOs";
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

