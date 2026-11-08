{ config, pkgs, ... }:

{

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd \"env GTK_THEME=Graphite-Mono niri-session\"";
        user = "greeter";
      };
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GTK_THEME = "Graphite-Mono";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    jetbrains-mono
  ];

  programs.niri.enable = true;
  programs.dconf.enable = true;
  services.printing.enable = true;
}
