{ lib, config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  i18n.defaultLocale = "en_GB.utf8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };
  time.timeZone = "Europe/Berlin";

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "slack" ];
  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    nodePackages.pyright
    direnv
    wmctrl
    spectacle
    element-desktop
    ripgrep
    coreutils
    fd
    slack
    tmux
    nodejs-14_x
    docker
    docker-compose
    wget
    neovim
    networkmanagerapplet

    xclip
    # (import ../../profiles/emacs.nix { inherit pkgs; })
    python3
    pciutils
    usbutils
    pass
    gnupg
    pinentry
    pinentry-qt
    chiaki
    kdeconnect
    duc
    unzip
    rnix-lsp
    cachix
    # plasma-browser-integration
    # browsers
    firefox
    brave
    nyxt

    #shells
    zsh
    elvish
    fish
  ];

  modules = {
    editors.emacs.enable = true;
    dev = {
      git.enable = true;
      tmux.enable = true;
    };
  };
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "qt";
    };
    gphoto2.enable = true;
    browserpass.enable = true;
    adb.enable = true;
    dconf.enable = true;
  };

  sound.enable = true;
  hardware = {
    pulseaudio.enable = true;
    bluetooth.enable = true;
    tuxedo-keyboard.enable = true;
  };
  virtualisation.docker.enable = true;
  services = {
    xserver = {
      enable = true;
      layout = "gb,de";
      xkbOptions = "eurosign:e,grp:caps_switch";
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      libinput = {
        enable = true;
        touchpad.clickMethod = "clickfinger";
      };
    };
    lorri.enable = true;
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
