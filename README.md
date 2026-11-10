# nixos

my nixos setup. niri on wayland, emacs for pretty much everything, set up for
c, assembly and security stuff (htb, courses, reversing, pwn).
it's a flake, with home manager pulled in as a nixos module.

## hosts

| host | machine | status |
|---|---|---|
| `alicebox` | desktop: ryzen 7 7800x3d, rx 7800 xt, 32 gb, two 1080p monitors | in use |
| `alicepad` | laptop: 2020 rog zephyrus g14 (ryzen 4000 + turing nvidia), mostly school/work | not installed yet |

## what's in it

- **desktop:** niri, waybar, fuzzel, fnott, swaybg, greetd + tuigreet, xwayland-satellite
- **look:** black, monochrome, one violet accent. graphite-mono gtk theme, papirus-dark (violet) icons, jetbrains mono everywhere
- **editor:** emacs (eglot with nixd, clangd and basedpyright, vertico/consult/embark, org-roam + dailies, org-noter, org-modern, org-download, pdf-tools, magit). packages come from nix, and `init.el` is live-linked so edits show up without a rebuild
- **assembly / reversing in emacs:** nasm-mode with asm-lsp, one-key build/run/debug, gdb many-windows, disaster and rmsbolt for c to asm, hex and elf views, x86-lookup into the intel sdm
- **security tools:** just what the emacs asm/c setup and reversing need: nasm, asm-lsp, gdb + gef, strace/ltrace, ghidra, radare2, imhex, binwalk. the offensive stuff (nmap, burp, pwntools, wireshark, the htb vpn) lives in the kali vm
- **virtualisation:** vmware workstation (for kali), distrobox on rootless podman for aur and `.deb` stuff
- **browser:** firefox with a transparent userchrome and a tui-style start page (`startpage/`) for home and new tabs
- **kernel / hardware:** stock nixos kernel on both hosts (with the vmware module fix), early amdgpu kms on alicebox, amd microcode, fwupd for device firmware
- **laptop (alicepad):** nixos-hardware g14 profile, nvidia prime offload (radeon runs the desktop, `nvidia-offload <app>` for the dgpu, which sleeps otherwise), asusd, power-profiles-daemon, battery + brightness in waybar
- **school (alicepad):** libreoffice, xournal++ for pdf annotating, pandoc + texlive for org/markdown to pdf, hunspell
- **backups (alicebox):** restic, daily, home dir to the storage drive (steam library and caches left out)
- **creative (alicebox):** krita, aseprite, davinci resolve (the free one, opencl through rocm), obs studio with a virtual camera, pipewire screen + per-app audio capture, vaapi encoding and vulkan game capture
- **games:** steam + gamemode, ring racers, prism launcher
- **other:** libreoffice, remmina + putty for remote sessions, spotify via spicetify, direnv + nix-direnv for per-project dev shells, nix-ld for prebuilt binaries, gh

## layout

```
.
├── flake.nix                       inputs, mkHost per machine, nixfmt-tree formatter
├── flake.lock
├── hosts/
│   ├── alicebox/
│   │   ├── configuration.nix       modules/nixos + gpu-amd, backup, obs, storage drive
│   │   ├── home.nix                modules/home + creative
│   │   └── hardware-configuration.nix
│   └── alicepad/
│       ├── configuration.nix       modules/nixos + nixos-hardware g14, laptop, nvidia power
│       ├── home.nix                modules/home + school, brightnessctl
│       └── hardware-configuration.nix  placeholder until the install generates the real one
├── lib/
│   └── vmware-kernel-fix.nix       signs vmmon/vmnet for whatever kernel a host uses
├── modules/
│   ├── nixos/                      system modules (default.nix imports the shared ones)
│   │   ├── backup.nix              daily restic of ~ to /mnt/storage (alicebox)
│   │   ├── base.nix                base packages, locale, networking, users
│   │   ├── boot.nix                grub, stock kernel + vmware fix, quiet boot
│   │   ├── desktop.nix             greetd + tuigreet, niri, fonts, gtk theme, keyd
│   │   ├── gaming.nix              steam, proton-ge, gamemode
│   │   ├── gpu-amd.nix             early amdgpu kms, rocm opencl (alicebox)
│   │   ├── hardware.nix            pipewire + rtkit, graphics, bluetooth, fwupd
│   │   ├── laptop.nix              power profiles, upower, lid (alicepad)
│   │   ├── nix.nix                 flakes, gc, store optimise, nix-ld
│   │   ├── obs.nix                 obs studio, virtual camera, plugins (alicebox)
│   │   └── virtualisation.nix      vmware workstation (no nat), podman + distrobox
│   └── home/                       home manager modules
│       ├── default.nix             shared, imported by hosts/<host>/home.nix
│       ├── creative.nix            krita, aseprite, davinci resolve (alicebox)
│       ├── dotfiles.nix            links dotfiles/common + dotfiles/<host> into ~/.config
│       ├── emacs.nix               emacs packages, lsp servers, live-linked init.el
│       ├── firefox.nix             profile, userchrome, start page as home + new tab
│       ├── packages.nix            apps, games, media, terminal, desktop plumbing
│       ├── school.nix              xournal++, pandoc, texlive, hunspell (alicepad)
│       ├── scripts.nix             toggle-mic, wallpicker
│       ├── security.nix            asm/debug + reversing tools, asm-lsp config, ssh kali
│       ├── shell.nix               fish + nix abbreviations, direnv, micro
│       ├── spotify.nix             spicetify
│       └── theme.nix               gtk, icons, dark mode, qt via gtk3 + adwaita-dark
├── dotfiles/
│   ├── common/                     niri (config.kdl), fuzzel, fnott, kitty, btop, fastfetch,
│   │                               gtk-theme, firefox/userChrome.css
│   ├── alicebox/                   niri/host.kdl (two monitors), waybar
│   └── alicepad/                   niri/host.kdl (laptop screen, brightness keys), waybar with battery
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

### niri keys

the ones i added on top of niri's defaults (`Mod+Shift+/` shows all of them):

| key | does |
|---|---|
| `Mod+Return` | kitty |
| `Mod+D` | fuzzel |
| `Mod+B` | firefox |
| `Mod+E` / `Mod+Shift+E` | emacs frame / emacs in kitty |
| `Mod+Space` | clipboard history |
| `Mod+M` | wallpicker |
| `Mod+Shift+M` | toggle mic |
| `Ctrl+Alt+Delete` | quit niri |

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

`.asm`/`.nasm` open in nasm-mode with asm-lsp, `.s`/`.S` in the built-in gas mode (no lsp, asm-lsp is set up for nasm and flags valid gas as errors).

| key | does |
|---|---|
| `C-c C-c` | build: `nasm -f elf64 -g -F dwarf` + `ld` (or `make` if there's a Makefile) |
| `C-c C-r` | run the binary in a `*vterm-run*` window at the bottom |
| `C-c C-d` | debug with emacs' gdb ui |
| `C-c C-g` | debug with gef in `*vterm-run*` |
| `C-c d` | disassemble the c line at point (disaster, intel syntax) |
| `C-c x` | look up the instruction at point in the intel sdm |

x86-lookup wants the sdm at `~/docs/intel-sdm.pdf`. every run gets a fresh `*vterm-run*` and kills the last one (gef included), your normal `*vterm*` is never touched.

### org notes

everything lives in `~/org/roam` (`courses/`, `htb/`, `daily/`, screenshots in `attachments/`).
restic backs it up with the rest of `~`. org-modern + olivetti for the look, mood-line in black for the modeline.

| key | does |
|---|---|
| `C-c n f` / `C-c n i` | find a note / insert a link to one |
| `C-c n c` | new note (default, course, course + pdf, htb box) |
| `C-c n n` | org-noter: open the note's pdf next to it, `i` in the pdf adds a note for that page |
| `C-c n d` / `C-c n t` / `C-c n y` / `C-c n D` | add to today's daily / open today / yesterday / pick a date |
| `C-c n r` | ripgrep through all notes |
| `C-c n b` / `C-c n o` / `C-c n l` | backlinks / forward links / backlink sidebar |
| `C-c n s` | screenshot a region (grim + slurp) into the note |
| `C-c n p` | paste an image from the clipboard into the note |
| `C-c a` | agenda over every org file in `~/org` |

course pdfs go in `~/docs/courses/`. the "course + pdf" template asks for one and links it.

htb notes run their shell blocks on the kali vm over tramp (`/ssh:kali:~/htb/<box>`). run the
`mkdir` block under recon once, then `C-c C-c` on any block runs it in kali and puts the output
underneath.

todo states are `TODO` `NEXT` `WAIT` → `DONE` / `DROP` (`C-c C-t`). deadlines with `C-c C-d`,
scheduled with `C-c C-s`, and they show up in the agenda.

### kali vm

two nics: `ethernet0` bridged (internet + htb vpn), `ethernet1` host-only with a static
`172.16.211.10`, which is what `ssh kali` (set up in `modules/home/security.nix`) and the htb notes use.
nat isn't an option here, see notes. inside kali:

```sh
sudo nmcli con add type ethernet ifname eth1 con-name hostonly ipv4.method manual \
  ipv4.addresses 172.16.211.10/24 ipv4.never-default yes ipv6.method ignore
sudo systemctl enable --now ssh
mkdir -p ~/.ssh && echo '<contents of ~/.ssh/id_ed25519.pub on the host>' >> ~/.ssh/authorized_keys
```

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
  `lib/vmware-kernel-fix.nix` wraps a host's kernel packages to sign them with `kmodigest`.
  pull the override once nixpkgs fixes it.
- **vmware nat:** `vmnet-natd` segfaults on start, so `/etc/vmware/networking` is
  written from `virtualisation.nix` with only vmnet1 (host-only) and no vmnet8 (nat).
  bridged and host-only work. the virtual network editor's changes get overwritten
  on the next switch, so change networks in that file instead.
- **niri per host:** `dotfiles/common/niri/config.kdl` ends with `include "host.kdl"`, so each
  host's outputs and extra binds live in `dotfiles/<host>/niri/host.kdl`. a second `binds { }`
  in the same file is an error, but an included file's binds get merged.
- **nvidia on alicepad:** the driver is unfree, so it's not in the nixos cache and gets built
  locally (a few minutes) whenever the kernel or driver changes.
- **zotero:** left out, the nixpkgs one depends on an insecure firefox esr. use the web version
  or a distrobox.
- **davinci resolve:** the free linux version can't import or export h.264/h.265 or aac, so
  transcode to dnxhr/prores with ffmpeg first, or just use kdenlive for those.
- **obs on niri:** use the "screen capture (pipewire)" source. for game capture, launch games
  with `obs-gamecapture %command%`.

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
4. if it gets different niri outputs/keys or waybar, add `dotfiles/<name>/niri/host.kdl` and `dotfiles/<name>/waybar/`.

### installing alicepad

from the nixos installer on the laptop, after partitioning (label the root `nixos` and the efi partition `boot`, or just use whatever the generated file says):

```sh
lspci -D | grep -E "VGA|3D"     # check the bus ids match the g14 profile (04:00.0 amd, 01:00.0 nvidia)
nix-shell -p git
git clone https://github.com/birdofscarlet/nixos /mnt/home/cardinal/nixconfig
cd /mnt/home/cardinal/nixconfig
nixos-generate-config --root /mnt --show-hardware-config > hosts/alicepad/hardware-configuration.nix
git add -A
nixos-install --flake .#alicepad
```

after the first boot, `chown -R cardinal:users ~/nixconfig` and commit the real hardware file.

## credits

started from [haaakez/nixos-configuration](https://github.com/haaakez/nixos-configuration),
which is where the original niri, waybar and theme setup came from. it has no license,
so anything here that's still derived from it is theirs, not mine to license.
i'm rewriting it over time.

## license

my own files are under the [wtfpl](LICENSE). this does **not** cover
the wallpapers (they belong to their artists) or anything still derived
from the upstream config above.
