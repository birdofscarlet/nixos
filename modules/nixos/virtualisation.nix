{ pkgs, ... }:
{
  virtualisation.vmware.host.enable = true;

  virtualisation.podman.enable = true;
  environment.systemPackages = [ pkgs.distrobox ];
}
