pkgs: kernelPackages:
kernelPackages.extend (
  _: super: {
    vmware = super.vmware.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        for m in "$out"/lib/modules/*/misc/*.ko; do
          ${pkgs.lib.getExe pkgs.buildPackages.kmodigest} "$m"
        done
      '';
    });
  }
)
