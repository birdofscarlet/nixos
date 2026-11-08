{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga401iv
    ../../modules/nixos
    ../../modules/nixos/laptop.nix
  ];

  boot.kernelPackages = import ../../lib/vmware-kernel-fix.nix pkgs pkgs.linuxPackages;

  hardware.nvidia.powerManagement = {
    enable = true;
    finegrained = true;
  };

  system.stateVersion = "26.11";
}
