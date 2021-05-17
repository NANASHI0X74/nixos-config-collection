# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot = {
    initrd = {
      luks.devices = {
        cryptroot = {
          device = "/dev/disk/by-uuid/53dbd74a-a4bc-4295-ac33-3294643994e7";
          preLVM = true;
        };
      };
    };
  };
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
  };

  networking = {
    interfaces.wlp0s20f3.useDHCP = true;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 8080 8000 ];
      allowedUDPPorts = [ 8080 8000 ];
      allowedTCPPortRanges = [
        # KDE Connect
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        # KDE Connect
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };
  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };
  time.timeZone = "Europe/Berlin";

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    nodePackages.pyright
    nixfmt
    direnv
    wmctrl
    spectacle
    element-desktop
    ripgrep
    coreutils
    fd
    clang
    slack
    tmux
    nodejs-14_x
    docker
    docker-compose
    arandr
    wget
    neovim
    git
    firefox
    networkmanagerapplet
    brave
    xclip
    virt-manager
    (import ../../components/emacs.nix { inherit pkgs; })
    python3
    pciutils
    usbutils
    pass
    gnupg
    pinentry
    pinentry-qt
    chiaki
    hplipWithPlugin
    kdeconnect
    duc
    unzip
    # plasma-browser-integration

    #shells
    zsh
    elvish
    fish
  ];
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "qt";
  };
  programs.gphoto2.enable = true;
  programs.browserpass.enable = true;
  programs.adb.enable = true;
  programs.dconf.enable = true;
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    extraConfig = "set -g mouse on";
    newSession = true;
  };

  sound.enable = true;
  hardware = {
    pulseaudio = {
      enable = true;
      configFile = ../../non-nix/pulseaudio/default.pa;
    };
    bluetooth.enable = true;
  };

  services = {
    xserver = {
      enable = true;
      layout = "gb";
      xkbOptions = "eurosign:e";
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      libinput = {
        enable = true;
        touchpad.clickMethod = "clickfinger";
      };
    };
    printing = {
      enable = true;
      drivers = with pkgs; [ gutenprint hplip hplipWithPlugin ];
    };
    lorri.enable = true;
    blueman.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
    };

  };
  #fix for displaymanager not starting on boot
  systemd.services = {
    display-manager.wants = [
      "systemd-user-sessions.service"
      "multi-user.target"
      "network-online.target"
    ];
    display-manager.after = [
      "systemd-user-sessions.service"
      "multi-user.target"
      "network-online.target"
    ];
  };

  # services.xserver.videoDrivers = [ "nvidia" ];

  # hardware.nvidia = {
  #   prime = {
  #     offload.enable = true;
  #     nvidiaBusId = "PCI:1:0:0";
  #     intelBusId = "PCI:0:2:0";
  #   };
  # };
  # security.pam.services.logind.fprintAuth = true;

  users = {
    groups = { nixosadmin = { }; };
    users.nanashi = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "disk"
        "networkmanager"
        "camera"
        "docker"
        "adbusers"
        "libvirtd"
        "nixosadmin"
      ];
      group = "users";
      shell = pkgs.fish;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
