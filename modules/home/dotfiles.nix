{
  hostname,
  lib,
  pkgs,
  ...
}:

let
  common = ../../dotfiles/common;
  host = ../../dotfiles/${hostname};
in
{
  xdg.configFile = {
    "niri/config.kdl".source = "${common}/niri/config.kdl";
    "niri/host.kdl".source = "${host}/niri/host.kdl";
    "waybar".source = "${host}/waybar";
    "fuzzel".source = "${common}/fuzzel";
    "fnott".source = "${common}/fnott";
    "kitty".source = "${common}/kitty";
    "fastfetch".source = "${common}/fastfetch";
    "btop".source = "${common}/btop";
  };

  systemd.user.services.waybar = {
    Unit = {
      Description = "Waybar";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      X-Restart-Triggers = [ "${host}/waybar" ];
    };
    Service = {
      ExecStart = lib.getExe pkgs.waybar;
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
