{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # apps (firefox comes from programs.firefox)
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
