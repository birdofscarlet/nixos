{ config, pkgs, ... }:
{
  # greeter
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd \"env GTK_THEME=Graphite-Mono niri-session\"";
        user = "greeter";
      };
    };
  };

  # session
  programs.niri.enable = true;
  programs.dconf.enable = true;
  services.printing.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GTK_THEME = "Graphite-Mono";
  };

  # theme
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    jetbrains-mono
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "JetBrains Mono" ];

  environment.systemPackages = [
    config.home-manager.users.cardinal.gtk.theme.package
  ];

  # input
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.capslock = "layer(control)";
    };
  };
}
