{ lib, pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = lib.mkDefault true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  programs.gamemode.enable = true;
}
