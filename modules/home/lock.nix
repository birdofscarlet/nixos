{
  config,
  lib,
  pkgs,
  ...
}:

let
  lock = "${lib.getExe config.programs.swaylock.package} -f";
in
{
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

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 600;
        command = lock;
      }
      {
        timeout = 900;
        command = "${lib.getExe pkgs.niri} msg action power-off-monitors";
      }
    ];
    events = {
      before-sleep = lock;
      lock = lock;
    };
  };
}
