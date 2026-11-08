{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

  nix.settings = {
    extra-substituters = [ "https://cache.lantian.pub/lantian" ];
    extra-trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];
  };

  boot.kernelPackages =
    import ../../lib/vmware-kernel-fix.nix pkgs
      pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;
}
