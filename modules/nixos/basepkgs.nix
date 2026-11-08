{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    git
    gcc
    python3
    nautilus
    bubblewrap
  ];

}
