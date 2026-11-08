{ pkgs, ... }:
{
  virtualisation.vmware.host.enable = true;
  environment.etc."vmware/networking" = {
    mode = "0644";
    text = ''
      VERSION=1,0
      answer VNET_1_DHCP yes
      answer VNET_1_DHCP_CFG_HASH 677C1A5D3FC20EC30DC76F70BFF820D0BA1C010D
      answer VNET_1_HOSTONLY_NETMASK 255.255.255.0
      answer VNET_1_HOSTONLY_SUBNET 172.16.211.0
      answer VNET_1_VIRTUAL_ADAPTER yes
    '';
  };

  virtualisation.podman.enable = true;
  environment.systemPackages = [ pkgs.distrobox ];
}
