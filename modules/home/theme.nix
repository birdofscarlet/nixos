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

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };
}
