{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ../../modules/nixos ];

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-label/storage";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" "nofail" ];
  };

  programs.dconf.enable = true;

  networking.hostName = "alicebox";
  networking.networkmanager.enable = true;

  # --- CORE SERVICES,SYSTEM PROGRAMS ---


  programs.fish.enable = true;
  # --- ENVIRONMENT,USER ---

  environment.systemPackages = with pkgs; [
    config.home-manager.users.cardinal.gtk.theme.package
    git
    gcc
    gpp
    fish
    python3
    nautilus
    bubblewrap
    signal-desktop
  ];

  users.users.cardinal = {
    isNormalUser = true;
    description = "cardinal";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    shell = pkgs.fish;
  };

  system.stateVersion = "25.11";
}
