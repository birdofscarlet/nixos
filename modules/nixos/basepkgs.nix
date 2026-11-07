{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    git
    gcc
    gpp
    python3
    nautilus
    bubblewrap
  ];

}
