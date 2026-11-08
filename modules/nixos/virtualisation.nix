# VMware Workstation host (for the Kali VM). Bundle is fetched by nixpkgs; vmmon/vmnet build against the kernel.
{ pkgs, lib, ... }:
{
  virtualisation.vmware.host.enable = true;

  # Workaround: nixpkgs' vmware-modules copies vmmon/vmnet in by hand, so they never get
  # the per-module signature + .ko.cer that kernel-modules aggregation now expects
  # ("cat: misc/vmmon.ko.cer: No such file or directory"). Sign them the way kbuild does.
  # Remove once nixpkgs fixes pkgs/os-specific/linux/vmware.
  boot.kernelPackages = pkgs.linuxPackages.extend (
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
