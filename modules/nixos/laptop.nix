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

  # network
  networking.networkmanager.wifi.macAddress = "stable-ssid";
  programs.steam.remotePlay.openFirewall = false;
}
