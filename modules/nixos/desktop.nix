{ config, pkgs, ... }:

{

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd \"env QT_QPA_PLATFORMTHEME=qt6ct GTK_THEME=Graphite-Mono niri-session\"";
        user = "greeter";
      };
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GTK_THEME = "Graphite-Mono";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };
  environment.sessionVariables = {
    QT_STYLE_OVERRIDE = "Breeze-Dark";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    jetbrains-mono
  ];

  programs.niri.enable = true;
  programs.dconf.enable = true;
  services.printing.enable = true;
}
