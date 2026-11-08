{ pkgs, lib, ... }:
{
  virtualisation.vmware.host.enable = true;

  virtualisation.podman.enable = true;
  environment.systemPackages = [ pkgs.distrobox ];

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
