{ ... }:
{
  # audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # bluetooth
  hardware.bluetooth.enable = true;

  # firmware
  services.fwupd.enable = true;
}
