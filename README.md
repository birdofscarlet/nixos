# alicebox

My NixOS setup: flake + home-manager, niri on Wayland, and a monochrome
"TUI" look across the terminal, bar, GTK, Firefox, Emacs and Spotify.

<!-- TODO: screenshot -->

## Stack

| | |
|---|---|
| OS | NixOS (unstable), flakes, home-manager |
| Desktop | niri, waybar, fuzzel, fnott, swaybg, greetd + tuigreet |
| Terminal / shell | kitty, fish |
| Editor | Emacs (daemon) |
| Browser | Firefox, TUI theme, custom start page |
| Theme | Graphite-Mono (GTK), Papirus-Dark violet, JetBrains Mono |
| Gaming | Steam + Proton-GE, gamemode, gamescope |

## Hosts

| host | machine |
|---|---|
| `alicebox` | desktop: Ryzen 7 7800X3D, RX 7800 XT, 32 GB DDR5, ASRock B650M PG Riptide WiFi, 2x HP X24ih 1080p/144 Hz |
| `alicepad` | TODO |

## Layout

    flake.nix        one mkHost function builds every host
    hosts/<name>/    per-machine config + hardware-configuration.nix
    modules/nixos/   shared system modules
    modules/home/    shared home-manager modules
    dotfiles/        raw app configs (niri, waybar, kitty, ...)
    emacs/           init.el + themes/
    startpage/       browser start page
    Wallpapers/

## Install

    git clone https://github.com/birdofscarlet/nixos ~/nixconfig
    cd ~/nixconfig
    # new machine only:
    sudo nixos-generate-config --show-hardware-config > hosts/<name>/hardware-configuration.nix
    sudo nixos-rebuild switch --flake .#<name>

## Day to day

    sudo nixos-rebuild switch --flake .#alicebox   # apply changes
    nix flake update                               # bump inputs, then rebuild
    sudo nixos-rebuild switch --rollback           # undo the last switch
    nix-collect-garbage -d                         # free space

## Where do I change...

| ...this | edit this |
|---|---|
| keybinds, monitors | `dotfiles/<host>/niri/config.kdl` |
| the bar | `dotfiles/<host>/waybar/` |
| colors and fonts | `modules/home/theming.nix` |
| packages | `modules/home/packages.nix` |
| games | `modules/nixos/gaming.nix` |

## Credits

Started from [haaakez/nixos-configuration](https://github.com/haaakez/nixos-configuration).
Built on nixpkgs, home-manager, spicetify-nix, textfox, nix-flatpak and
nix-cachyos-kernel.

## License

My own files are under the WTFPL (see `LICENSE`).
The starting point was [haaakez/nixos-configuration](https://github.com/haaakez/nixos-configuration),
which has no license; those parts remain the original author's work.
Wallpapers belong to their respective creators and aren't covered by this license.

