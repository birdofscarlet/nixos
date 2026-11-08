# GTK / icons / Qt / dark mode.
{ config, pkgs, ... }:

let
  dots = ../../dotfiles/alicebox;
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

  # If a build complains about these two colliding with the gtk module,
  # delete them; gtk already installs both themes.
  home.file.".local/share/icons/Papirus-Dark".source =
    "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark";
  home.file.".local/share/themes/Graphite-Mono".source =
    "${config.gtk.theme.package}/share/themes/Graphite-Mono";

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # NOTE: Qt theming is split between here (gtk platform theme), the linked
  # qt5ct/qt6ct configs below, and QT_STYLE_OVERRIDE in modules/nixos/desktop.nix.
  # Left exactly as it was; pick one route later.
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  xdg.configFile = {
    "qt5ct".source = "${dots}/qt5ct";
    "qt6ct".source = "${dots}/qt6ct";
  };
}
