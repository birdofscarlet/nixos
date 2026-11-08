{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

  nix.settings = {
    extra-substituters = [ "https://cache.lantian.pub/lantian" ];
    extra-trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];
  };

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-lts-zen4.extend (
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
