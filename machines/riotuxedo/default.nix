{ lib, config, pkgs, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "ntfs" ];
  };

  networking = {
    hostName = "riotuxedo";
    interfaces = {
      enp53s0.useDHCP = true;
      wlp54s0.useDHCP = true;
    };
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
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };
  time.timeZone = "Europe/Berlin";
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "slack" "steam" "steam-run" "steam-original" ];
  environment = {
    systemPackages = with pkgs; [
      wl-clipboard
      qmk
      virt-manager
      gnome.gnome-boxes
      nixpkgs-fmt
      nodePackages.pyright
      wmctrl
      spectacle
      element-desktop
      file
      ripgrep
      coreutils
      fd
      slack
      tmux
      docker
      docker-compose
      wget
      neovim
      networkmanagerapplet
      kontact
      korganizer
      akonadi
      inputs.devenv.packages.x86_64-linux.devenv
      # kdav

      xclip
      python3
      pciutils
      usbutils

      # password store
      (pass.withExtensions
        (p: with p; [ pass-otp ]))
      gnupg

      keybase-gui
      chiaki
      plasma5Packages.kdeconnect-kde
      duc
      unzip
      rnix-lsp
      cachix
      # plasma-browser-integration

      # browsers
      firefox-wayland
      brave
      # nyxt
      tridactyl-native

      ytmdesktop
      #shells
      zsh
      elvish
    ];
    sessionVariables.NIXOS_OZONE_WL = "1";
  };
  modules = {
    editors.emacs.enable = true;
    dev = {
      git.enable = true;
      tmux.enable = true;
      direnv.enable = true;
    };
    desktop.enable = true;
    syncthing.enable = true;
    waydroid.enable = true;
  };
  programs = {
    fish.enable = true;
    steam.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    gphoto2.enable = true;
    browserpass.enable = true;
    adb.enable = true;
    dconf.enable = true;
  };

  hardware = {
    bluetooth.enable = true;
    tuxedo-keyboard.enable = true;
  };
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  security = {
    rtkit.enable = true;
  };
  services = {
    udev.packages = [
      pkgs.qmk-udev-rules
    ];
    lorri.enable = true;
    keybase.enable = true;
    kbfs.enable = true;
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };
  };
  users = {
    users.nanashi = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "disk"
        "networkmanager"
        "camera"
        "adbusers"
        "docker"
      ];
      group = "users";
      shell = pkgs.fish;
    };
  };
  system.stateVersion = "21.05";
}
