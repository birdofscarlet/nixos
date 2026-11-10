{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # apps
    vesktop
    discord
    signal-desktop
    gimp
    kdePackages.ark
    kdePackages.kdenlive
    pavucontrol
    prismlauncher
    libreoffice
    remmina
    putty
    openvpn

    # games
    ringracers

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
    ripgrep
    gamescope

    # desktop plumbing
    waybar
    playerctl
    swaybg
    fuzzel
    fnott
    polkit_gnome
    wl-clipboard
    cliphist
    grim
    slurp
    xwayland-satellite
    libnotify

    # cursor
    kdePackages.breeze
  ];
}
