{ pkgs, hostname, ... }:
{
  # packages
  environment.systemPackages = with pkgs; [
    git
    gcc
    python3
    nautilus
    bubblewrap
  ];

  # locale
  time.timeZone = "America/Chicago";
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
  };

  # networking
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # users
  programs.fish.enable = true;

  users.users.cardinal = {
    isNormalUser = true;
    description = "cardinal";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };
}
