{ ... }:
{
  # power
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # lid
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
}
