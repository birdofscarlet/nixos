{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # art
    aseprite
    krita

    # video
    davinci-resolve
  ];
}
