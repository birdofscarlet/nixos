{ ... }:
{
  services.restic.backups.home = {
    initialize = true;
    repository = "/mnt/storage/restic/home";
    passwordFile = "/root/restic-password";
    paths = [ "/home/cardinal" ];
    exclude = [
      "/home/cardinal/.cache"
      "/home/cardinal/.local/share/Steam"
      "/home/cardinal/.local/share/Trash"
      "/home/cardinal/.local/share/containers"
      "/home/cardinal/Downloads"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };

  systemd.services.restic-backups-home.unitConfig.RequiresMountsFor = [ "/mnt/storage" ];
}
