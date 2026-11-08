{ hostname, ... }:

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
}
