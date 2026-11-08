# nixos

my nixos setup. niri on wayland, emacs for pretty much everything, set up for
c, assembly and security stuff (htb, courses, reversing, pwn).
it's a flake, with home manager pulled in as a nixos module.

## hosts

| host | machine | status |
|---|---|---|
| `alicebox` | desktop: ryzen 7 7800x3d, rx 7800 xt, 32 gb, two 1080p monitors | in use |
| `alicepad` | laptop with an nvidia gpu | planned |

## what's in it

- **desktop:** niri, waybar, fuzzel, fnott, swaybg, greetd + tuigreet, xwayland-satellite
- **look:** black, monochrome, one violet accent. graphite-mono gtk theme, papirus-dark (violet) icons, jetbrains mono everywhere
- **editor:** emacs (eglot, vertico/consult/embark, org-roam, org-noter, pdf-tools, magit). packages come from nix, and `init.el` is live-linked so edits show up without a rebuild
- **assembly / reversing in emacs:** nasm-mode with asm-lsp, one-key build/run/debug, gdb many-windows, disaster and rmsbolt for c to asm, hex and elf views, x86-lookup into the intel sdm
- **security tools:** python env with pwntools/scapy/impacket, gdb + gef, ghidra, radare2, imhex, nmap, ffuf, gobuster, feroxbuster, sqlmap, burp suite, john, wireshark, openvpn for htb
- **virtualisation:** vmware workstation (for kali), distrobox on rootless podman for aur and `.deb` stuff
- **browser:** firefox with a transparent userchrome and a tui-style start page (`startpage/`) for home and new tabs
- **kernel / hardware:** cachyos kernel (latest, zen 4 build) from its binary cache, early amdgpu kms, amd microcode, fwupd for device firmware
- **backups:** restic, daily, home dir to the storage drive (steam library and caches left out)
- **creative:** krita, aseprite, davinci resolve (the free one, opencl through rocm), obs studio with a virtual camera, pipewire screen + per-app audio capture, vaapi encoding and vulkan game capture
- **games:** steam + gamemode, ring racers, prism launcher
- **other:** spotify via spicetify, direnv + nix-direnv for per-project dev shells, nix-ld for prebuilt binaries, gh

## layout

```
.
├── flake.nix                       inputs, mkHost per machine, nixfmt-tree formatter
├── flake.lock
├── hosts/
│   └── alicebox/
│       ├── configuration.nix       imports modules/nixos + gpu-amd, storage drive
│       └── hardware-configuration.nix
├── modules/
│   ├── nixos/                      system modules (default.nix imports all but gpu-*)
│   │   ├── backup.nix              daily restic of ~ to /mnt/storage
│   │   ├── base.nix                base packages, locale, networking, users
│   │   ├── boot.nix                grub, cachyos kernel + cache, vmware module fix
│   │   ├── desktop.nix             greetd + tuigreet, niri, fonts, gtk theme, keyd
│   │   ├── gaming.nix              steam, proton-ge, gamemode
│   │   ├── gpu-amd.nix             early amdgpu kms, rocm opencl (imported per host)
│   │   ├── hardware.nix            pipewire, graphics, bluetooth, fwupd
│   │   ├── nix.nix                 flakes, gc, store optimise, nix-ld
│   │   ├── obs.nix                 obs studio, virtual camera, plugins
│   │   ├── security.nix            wireshark
│   │   └── virtualisation.nix      vmware workstation, podman + distrobox
│   └── home/                       home manager modules
│       ├── default.nix
│       ├── dotfiles.nix            links dotfiles/<host>/ into ~/.config
│       ├── emacs.nix               emacs packages, live-linked init.el
│       ├── firefox.nix             profile, userchrome, start page as home + new tab
│       ├── packages.nix            apps, games, art, video, media, terminal, desktop plumbing
│       ├── scripts.nix             toggle-mic, wallpicker
│       ├── security.nix            htb / reversing / pwn tools, asm-lsp config
│       ├── shell.nix               fish + nix abbreviations, direnv, micro
│       ├── spotify.nix             spicetify
│       └── theme.nix               gtk, icons, dark mode, qt via gtk3 + adwaita-dark
├── dotfiles/
│   ├── alicebox/                   niri, waybar, fuzzel, fnott, kitty, btop, fastfetch,
│   │                               gtk-theme, firefox/userChrome.css
│   └── alicepad/                   laptop variant, getting replaced
├── emacs/
│   ├── init.el                     symlinked live into ~/.config/emacs
│   └── themes/graphite-mono-theme.el
├── startpage/                      browser start page (html/js, no build step)
│   ├── index.html
│   ├── app.js
│   └── links.js                    public links, links.local.js is gitignored
└── Wallpapers/                     see license
```

## usage

the repo needs to live at `~/nixconfig` since a few live symlinks point there.

```sh
git clone https://github.com/birdofscarlet/nixos ~/nixconfig
cd ~/nixconfig

nixos-rebuild build  --flake .#alicebox     # build only
sudo nixos-rebuild switch --flake .#alicebox
nix flake update                             # bump inputs (commit flake.lock on its own)
nix fmt                                      # format all the nix files
```

flakes only see files git is tracking, so `git add` new files before building.
run `git` as yourself, not under `sudo`.

### shell shortcuts

fish abbreviations. they expand in place, so you see the whole command before it runs:

| abbr | expands to |
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

there's also two functions: `nrbd` builds and shows `nix store diff-closures` against the running system, and `nfmt` runs `nix fmt` in the repo.

### live-editable files

these are symlinked to the repo, so edits kick in without a rebuild:
`emacs/init.el`, `emacs/themes/`, `startpage/`.
everything else in `dotfiles/` needs a rebuild.

### start page

`startpage/links.js` has the public links. private ones go in
`startpage/links.local.js`, which is gitignored. if a group in the local file
has the same title as a public one, they get merged. type to filter, arrows to
select, enter to open. anything else you type gets opened as a url or searched.

### assembly in emacs

`.asm`/`.nasm` open in nasm-mode, `.s`/`.S` in the built-in gas mode.

| key | does |
|---|---|
| `C-c C-c` | build: `nasm -f elf64 -g -F dwarf` + `ld` (or `make` if there's a Makefile) |
| `C-c C-r` | run the binary in vterm |
| `C-c C-d` | debug with emacs' gdb ui |
| `C-c C-g` | debug with gef in vterm |
| `C-c d` | disassemble the c line at point (disaster, intel syntax) |
| `C-c x` | look up the instruction at point in the intel sdm |

x86-lookup wants the sdm at `~/docs/intel-sdm.pdf`.

### distrobox

```sh
distrobox create --name arch --image archlinux:latest   # aur via yay/paru
distrobox create --name deb  --image debian:stable      # .deb packages
distrobox enter arch
distrobox-export --app <name>          # inside the box: add a launcher
distrobox-export --bin /usr/bin/<tool> # inside the box: put a binary in ~/.local/bin
```

boxes share your home dir, so clone aur stuff somewhere that isn't this repo.

## notes

- **vmware kernel modules:** nixpkgs' `vmware-modules` doesn't sign vmmon/vmnet,
  which breaks the kernel-modules build (`cat: misc/vmmon.ko.cer: No such file or directory`).
  `modules/nixos/boot.nix` overrides it to sign them with `kmodigest`.
  pull the override once nixpkgs fixes it.
- **cachyos kernel:** uses the `pinned` overlay so kernels come from the
  `cache.lantian.pub` binary cache. on a fresh install, switch once with the cache
  settings before turning the kernel on, or it gets compiled locally.
- **davinci resolve:** the free linux version can't import or export h.264/h.265 or aac, so
  transcode to dnxhr/prores with ffmpeg first, or just use kdenlive for those.
- **obs on niri:** use the "screen capture (pipewire)" source. for game capture, launch games
  with `obs-gamecapture %command%`.
- **python tools:** pwntools already ships `ROPgadget` and `checksec`, so don't add those as separate packages.

### backups

restic runs daily as root and backs up `~` to `/mnt/storage/restic/home`
(keeps 7 daily, 4 weekly, 6 monthly snapshots). the password lives in `/root/restic-password`,
outside the repo. keep a copy somewhere else or the backup can't be restored.

```sh
sudo systemctl start restic-backups-home   # run it now
sudo restic -r /mnt/storage/restic/home -p /root/restic-password snapshots
sudo restic -r /mnt/storage/restic/home -p /root/restic-password restore latest --target /tmp/restore --include /home/cardinal/org
```

the unit needs `/mnt/storage` mounted, so it fails instead of writing to the root drive.

## adding a machine

1. `mkdir hosts/<name>` and generate `hardware-configuration.nix` on the machine
   (`nixos-generate-config --show-hardware-config`).
2. add `hosts/<name>/configuration.nix` (import `../../modules/nixos` and the hardware file)
   and `hosts/<name>/home.nix` (import `../../modules/home` plus host-only bits).
3. add one `mkHost` line to `flake.nix`.

## credits

started from [haaakez/nixos-configuration](https://github.com/haaakez/nixos-configuration),
which is where the original niri, waybar and theme setup came from. it has no license,
so anything here that's still derived from it is theirs, not mine to license.
i'm rewriting it over time.

## license

my own files are under the [wtfpl](LICENSE). this does **not** cover
the wallpapers (they belong to their artists) or anything still derived
from the upstream config above.
