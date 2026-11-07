{ pkgs, config, ... }:

{

  environment.systemPackages = with pkgs; [
    config.home-manager.users.cardinal.gtk.theme.package
  ];

}
