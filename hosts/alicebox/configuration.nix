{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options= "--delete-older-than 7d";
  };
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cnijfilter2 ];
systemd.services.simple-input-overlay = {
  description = "Simple Input Overlay Event & MPRIS Server";
  wantedBy = [ "multi-user.target" ];
  after = [ "network.target" "sound.target" ];

  path = with pkgs; [
    playerctl
    (python3.withPackages (ps: with ps; [
      websockets
      evdev
    ]))
  ];

  # Allow the service to speak to user-level D-Bus (Spotify/MPRIS)
  environment = {
    DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
    XDG_RUNTIME_DIR = "/run/user/1000";
  };

  serviceConfig = {
    Type = "simple";
    User = "cardinal";
    SupplementaryGroups = [ "input" ];
    WorkingDirectory = "/home/cardinal/obs-utils";
    ExecStart = "${pkgs.python3.withPackages (ps: with ps; [ websockets evdev ])}/bin/python3 /home/cardinal/obs-utils/server.py";
    Restart = "always";
    RestartSec = 3;
  };
};

services.keyd = {
  enable = true;
  keyboards.default = {
    ids = [ "*" ];
    settings.main.capslock = "leftcontrol";
  };
};

  # --- BOOT,HARDWARE ---
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.theme = pkgs.minimal-grub-theme;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
  };
  boot.consoleLogLevel = 0;
  boot.kernelParams = [ "quiet" "udev.log_level=3" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.dconf.enable = true;

  networking.hostName = "alicebox";
  networking.networkmanager.enable = true;
  time.timeZone = "US/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  # --- CORE SERVICES,SYSTEM PROGRAMS ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd \"env QT_QPA_PLATFORMTHEME=qt6ct GTK_THEME=Graphite-Mono niri-session\"";
        user = "greeter";
      };
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };
  programs.obs-studio = {
  	enable=true;
  	package=(pkgs.obs-studio.override { cudaSupport = true; });
  	plugins = with pkgs.obs-studio-plugins; [
  		wlrobs
  		obs-pipewire-audio-capture
  		obs-vkcapture
  	];
  };

  programs.gamemode.enable = true;
  programs.niri.enable = true;
  programs.fish.enable = true;
  # --- ENVIRONMENT,USER ---
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GTK_THEME = "Graphite-Mono";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };
  environment.sessionVariables = {
    QT_STYLE_OVERRIDE = "Breeze-Dark";
  };
  services.flatpak.enable = true;
  services.flatpak.remotes = [{
    name = "flathub";
    location = "https://flathub.org";
  }];
  services.flatpak.packages = [
    "flathub;org.vinegarhq.Sober"
  ];

  environment.systemPackages = with pkgs; [
      config.home-manager.users.cardinal.gtk.theme.package
      git
      gcc
      gpp
      fish
      python3
      nautilus
      bubblewrap
    ];

  nixpkgs.config.allowUnfree = true;

  users.users.cardinal = {
    isNormalUser = true;
    description = "cardinal";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    shell = pkgs.fish;
  };
  fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      jetbrains-mono
    ];

  system.stateVersion = "25.11";
}
