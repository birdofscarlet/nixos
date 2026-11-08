# nixos

My NixOS setup: **niri** on Wayland, **Emacs** as the main tool, built for
C, assembly and security work (HTB, courses, reversing, pwn).
Flake-based, with Home Manager as a NixOS module.

## Hosts

| Host | Machine | Status |
|---|---|---|
| `alicebox` | Desktop: Ryzen 7 7800X3D, RX 7800 XT, 32 GB, two 1080p monitors | in use |
| `alicepad` | Laptop with an NVIDIA GPU | planned |

## What's in it

- **Desktop:** niri, waybar, fuzzel, fnott, swaybg, greetd + tuigreet, xwayland-satellite
- **Look:** black, monochrome, one violet accent. Graphite-Mono GTK theme, Papirus-Dark (violet) icons, JetBrains Mono everywhere
- **Editor:** Emacs (eglot, vertico/consult/embark, org-roam, org-noter, pdf-tools, magit). Packages come from Nix; `init.el` is live-linked so edits apply without a rebuild
- **Browser:** Firefox with a transparent userChrome and a TUI-style start page (`startpage/`)
- **Other:** Spotify via spicetify, Steam + gamemode, direnv + nix-direnv for per-project dev shells

## Layout

```
flake.nix                 inputs, and one mkHost call per machine
hosts/<host>/             per-machine config: hardware, disks, host-only bits
modules/nixos/            system modules shared by every host
modules/home/             Home Manager modules (theme, firefox, emacs, packages, ...)
dotfiles/<host>/          config directories copied into ~/.config
emacs/                    init.el and themes, symlinked live into ~/.config/emacs
startpage/                browser start page (html/js/css, no build step)
Wallpapers/               wallpapers (see License)
```

## Usage

The repo is expected at `~/nixconfig` (a few live symlinks point there).

```sh
git clone https://github.com/birdofscarlet/nixos ~/nixconfig
cd ~/nixconfig

nixos-rebuild build  --flake .#alicebox     # build only
sudo nixos-rebuild switch --flake .#alicebox
nix flake update                             # bump inputs (commit flake.lock separately)
nix fmt                                      # format all nix files
```

Flakes only see files tracked by git, so `git add` new files before building.
Run `git` as your own user, not under `sudo`.

### Live-editable files

These are symlinked to the repo, so edits take effect without a rebuild:
`emacs/init.el`, `emacs/themes/`, `startpage/`.
Everything else in `dotfiles/` needs a rebuild.

### Start page

`startpage/links.js` holds the public links. Private ones go in
`startpage/links.local.js`, which is gitignored. A group with the same title
in the local file is merged into the public one. Type to filter, arrows to
select, Enter to open; anything else typed is opened as a URL or searched.

## Adding a machine

1. `mkdir hosts/<name>` and generate `hardware-configuration.nix` on the machine
   (`nixos-generate-config --show-hardware-config`).
2. Add `hosts/<name>/configuration.nix` (import `../../modules/nixos` and the hardware file)
   and `hosts/<name>/home.nix` (import `../../modules/home` plus host-only bits).
3. Add one `mkHost` line to `flake.nix`.

## Credits

Started from [haaakez/nixos-configuration](https://github.com/haaakez/nixos-configuration),
the source of the original niri, waybar and theme setup. It has no license,
so parts of this repo that remain derived from it are theirs, not mine to license.
I'm rewriting them over time.

## License

My own files are under the [WTFPL](LICENSE). This does **not** cover:
the wallpapers (they belong to their respective artists), and any content
still derived from the upstream config above.
