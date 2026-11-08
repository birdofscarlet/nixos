{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ../../modules/nixos/gpu-amd.nix
    ../../modules/nixos/kernel-cachyos.nix
    ../../modules/nixos/backup.nix
    ../../modules/nixos/obs.nix
  ];

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-label/storage";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "nofail"
    ];
  };

  system.stateVersion = "25.11";
}
