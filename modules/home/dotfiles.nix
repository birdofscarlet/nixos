{ ... }:

let
  dots = ../../dotfiles/alicebox;
in
{
  xdg.configFile = {
    "niri".source = "${dots}/niri";
    "waybar".source = "${dots}/waybar";
    "fuzzel".source = "${dots}/fuzzel";
    "fnott".source = "${dots}/fnott";
    "kitty".source = "${dots}/kitty";
    "fastfetch".source = "${dots}/fastfetch";
    "btop".source = "${dots}/btop";
  };
}
