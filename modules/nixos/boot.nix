{
  inputs,
  pkgs,
  lib,
  ...
}:
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

  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
  ];

  # kernel
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

  nix.settings = {
    extra-substituters = [ "https://cache.lantian.pub/lantian" ];
    extra-trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];
  };

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4.extend (
    _: super: {
      vmware = super.vmware.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          for m in "$out"/lib/modules/*/misc/*.ko; do
            ${lib.getExe pkgs.buildPackages.kmodigest} "$m"
          done
        '';
      });
    }
  );
}
