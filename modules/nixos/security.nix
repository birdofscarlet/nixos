{ pkgs, ... }:
{
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  users.users.cardinal.extraGroups = [ "wireshark" ];
}
