{ config, pkgs, ... }:

{

  programs.fish.enable = true;

  users.users.cardinal = {
    isNormalUser = true;
    description = "cardinal";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

}
