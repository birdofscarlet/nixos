{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # apps
    vesktop
    signal-desktop
    gimp
    kdePackages.ark
    kdePackages.kdenlive
    pavucontrol
    prismlauncher

    # media
    mpv
    imv
    cava
    mangohud
    gphoto2

    # terminal
    kitty
    fastfetch
    btop
    gh
    yazi
    cmatrix
    peaclock
    tree
    gamescope

    # desktop plumbing
    waybar
    swaybg
    fuzzel
    wallust
    fnott
    polkit_gnome
    wl-clipboard
    cliphist
    grim
    slurp
    xwayland-satellite
    libnotify

    # qt theming
    kdePackages.breeze
    kdePackages.qt6ct
    libsForQt5.qt5ct
  ];
}
