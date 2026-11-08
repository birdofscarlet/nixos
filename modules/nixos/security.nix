# System-level bits for security work. User tools live in modules/home/security.nix.
{ pkgs, ... }:
{
  # dumpcap gets capture capabilities; members of "wireshark" can sniff without root
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  users.users.cardinal.extraGroups = [ "wireshark" ];
}
