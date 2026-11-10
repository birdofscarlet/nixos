{ pkgs, ... }:
{
  # bootloader
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.theme = pkgs.minimal-grub-theme;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    configurationLimit = 10;
  };

  # kernel
  boot.kernelPackages = import ../../lib/vmware-kernel-fix.nix pkgs pkgs.linuxPackages;

  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
  ];
}
