{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ../../modules/nixos ];

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-label/storage";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" "nofail" ];
  };

  system.stateVersion = "25.11";
}
