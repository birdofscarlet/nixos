{ config, pkgs, ... }:

let
  dots = ../../dotfiles/common;
in
{
  gtk = {
    enable = true;
    theme = {
      name = "Graphite-Mono";
      package = pkgs.runCommand "graphite-mono-gtk-theme" { } ''
        mkdir -p "$out/share/themes"
        cp -r ${dots}/gtk-theme "$out/share/themes/Graphite-Mono"
      '';
    };
    gtk4.theme = config.gtk.theme;
    font = {
      name = "JetBrains Mono";
      size = 11;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = (pkgs.papirus-icon-theme.override { color = "violet"; }).overrideAttrs {
        dontFixup = true;
      };
    };
  };

  home.file.".local/share/icons/Papirus-Dark".source =
    "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark";
  home.file.".local/share/themes/Graphite-Mono".source =
    "${config.gtk.theme.package}/share/themes/Graphite-Mono";

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      font = "JetBrains Mono";
      indicator-radius = 80;
      indicator-thickness = 6;
      inside-color = "000000";
      inside-clear-color = "000000";
      inside-ver-color = "000000";
      inside-wrong-color = "000000";
      ring-color = "222222";
      ring-clear-color = "777777";
      ring-ver-color = "c4a7e7";
      ring-wrong-color = "d08770";
      key-hl-color = "c4a7e7";
      bs-hl-color = "d08770";
      line-color = "00000000";
      line-clear-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      separator-color = "00000000";
      text-color = "cccccc";
      text-clear-color = "cccccc";
      text-ver-color = "c4a7e7";
      text-wrong-color = "d08770";
      show-failed-attempts = true;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };
}
