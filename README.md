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
- **Assembly / reversing in Emacs:** nasm-mode with asm-lsp, one-key build/run/debug, gdb many-windows, disaster and rmsbolt for C to asm, hex and ELF views, x86-lookup into the Intel SDM
- **Security tools:** pwntools/scapy/impacket Python env, gdb + gef, ghidra, radare2, imhex, nmap, ffuf, gobuster, feroxbuster, sqlmap, Burp Suite, john, Wireshark, openvpn for HTB
- **Virtualisation:** VMware Workstation (for Kali), distrobox on rootless podman for AUR and `.deb` packages
- **Browser:** Firefox with a transparent userChrome and a TUI-style start page (`startpage/`)
- **Other:** Spotify via spicetify, Steam + gamemode, direnv + nix-direnv for per-project dev shells, nix-ld for prebuilt binaries, gh

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

### Shell shortcuts

fish abbreviations (they expand in place, so you see the full command before it runs):

| Abbr | Expands to |
|---|---|
| `nrbs` / `nrbt` / `nrbo` | `sudo nixos-rebuild switch` / `test` / `boot --flake ~/nixconfig` |
| `nrbb` | `nixos-rebuild build --flake ~/nixconfig` |
| `nrbr` | `sudo nixos-rebuild switch --rollback` |
| `ngen` | `nixos-rebuild list-generations` |
| `nfu` / `nfc` | `nix flake update` / `nix flake check` on the repo |
| `nrepl` | `nix repl` with this flake loaded |
| `nse` | `nix search nixpkgs` |
| `nsh` / `nrun` | `nix shell nixpkgs#` / `nix run nixpkgs#`, cursor after the `#` |
| `ngc` | `sudo nix-collect-garbage --delete-older-than 7d` |
| `nopt` | `nix store optimise` |

Functions: `nrbd` builds and shows `nix store diff-closures` against the running system; `nfmt` runs `nix fmt` in the repo.

### Live-editable files

These are symlinked to the repo, so edits take effect without a rebuild:
`emacs/init.el`, `emacs/themes/`, `startpage/`.
Everything else in `dotfiles/` needs a rebuild.

### Start page

`startpage/links.js` holds the public links. Private ones go in
`startpage/links.local.js`, which is gitignored. A group with the same title
in the local file is merged into the public one. Type to filter, arrows to
select, Enter to open; anything else typed is opened as a URL or searched.

### Assembly in Emacs

`.asm`/`.nasm` open in nasm-mode, `.s`/`.S` in the built-in GAS mode.

| Key | Action |
|---|---|
| `C-c C-c` | build: `nasm -f elf64 -g -F dwarf` + `ld` (or `make` if there's a Makefile) |
| `C-c C-r` | run the binary in vterm |
| `C-c C-d` | debug with Emacs' gdb UI |
| `C-c C-g` | debug with gef in vterm |
| `C-c d` | disassemble the C line at point (disaster, Intel syntax) |
| `C-c x` | look up the instruction at point in the Intel SDM |

x86-lookup expects the SDM at `~/docs/intel-sdm.pdf`.

### distrobox

```sh
distrobox create --name arch --image archlinux:latest   # AUR via yay/paru
distrobox create --name deb  --image debian:stable      # .deb packages
distrobox enter arch
distrobox-export --app <name>          # inside the box: add a launcher
distrobox-export --bin /usr/bin/<tool> # inside the box: put a binary in ~/.local/bin
```

Boxes share your home directory, so clone AUR packages somewhere outside this repo.

## Notes

- **VMware kernel modules:** nixpkgs' `vmware-modules` doesn't sign vmmon/vmnet,
  which breaks the kernel-modules build (`cat: misc/vmmon.ko.cer: No such file or directory`).
  `modules/nixos/virtualisation.nix` overrides it to sign them with `kmodigest`.
  Remove the override once nixpkgs is fixed.
- **Python tools:** pwntools already ships `ROPgadget` and `checksec`, so don't add those packages separately.

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
