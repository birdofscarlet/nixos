{ pkgs, ... }:

{
  imports = [
    ../../modules/home
    ../../modules/home/school.nix
  ];

  home.packages = [ pkgs.brightnessctl ];

  home.stateVersion = "26.11";
}
