{ config, pkgs, inputs, ... }:

let
  dots = ./dotfiles/alicebox;
  repo = "${config.home.homeDirectory}/nixconfig";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  home.username = "cardinal";
  home.homeDirectory = "/home/cardinal";
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];

  # ── dotfiles ──────────────────────────────────────────────────────────
  xdg.configFile = {
    "niri".source = "${dots}/niri";
    "waybar".source = "${dots}/waybar";
    "fuzzel".source = "${dots}/fuzzel";
    "fnott".source = "${dots}/fnott";
    "kitty".source = "${dots}/kitty";
    "fastfetch".source = "${dots}/fastfetch";
    "btop".source = "${dots}/btop";
    "qt5ct".source = "${dots}/qt5ct";
    "qt6ct".source = "${dots}/qt6ct";

    # live-editable, no rebuild needed
    "emacs/init.el".source = link "${repo}/emacs/init.el";
    "emacs/themes".source = link "${repo}/emacs/themes";
  };

  home.file."startpage".source = link "${repo}/startpage";

  # ── theme ─────────────────────────────────────────────────────────────
  gtk = {
    enable = true;
    theme = {
      name = "Graphite-Mono";
      package = pkgs.runCommand "graphite-mono-gtk-theme" { } ''
        mkdir -p "$out/share/themes"
        cp -r ${dots}/gtk-theme "$out/share/themes/Graphite-Mono"
      '';
    };
    gtk4.theme = config.gtk.theme;
    font = {
      name = "JetBrains Mono";
      size = 11;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = (pkgs.papirus-icon-theme.override { color = "violet"; }).overrideAttrs {
        dontFixup = true;
      };
    };
  };

  # If a build complains about these two colliding with the gtk module,
  # delete them; gtk already installs both themes.
  home.file.".local/share/icons/Papirus-Dark".source =
    "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark";
  home.file.".local/share/themes/Graphite-Mono".source =
    "${config.gtk.theme.package}/share/themes/Graphite-Mono";

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # NOTE: Qt theming is split between here (gtk platform theme), the linked
  # qt5ct/qt6ct configs above, and QT_STYLE_OVERRIDE in modules/nixos/desktop.nix.
  # Left exactly as it was; pick one route later.
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # ── firefox ───────────────────────────────────────────────────────────
  programs.firefox = {
    enable = true;
    profiles.cardinal = {
      isDefault = true;
      settings = {
        "widget.wayland.transparent-background" = true;
        "widget.transparent-windows" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "gfx.webrender.all" = true;
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "always-show";
        "browser.toolbars.bookmarks.visibility" = "never";

        # start page
        "browser.startup.page" = 1; # 1 = open the homepage
        "browser.startup.homepage" = "file://${config.home.homeDirectory}/startpage/index.html";
        "browser.newtabpage.enabled" = false;
      };
      userChrome = builtins.readFile "${dots}/firefox/userChrome.css";
    };
  };

  # ── spotify ───────────────────────────────────────────────────────────
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.text;
      colorScheme = "custom";
      customColorScheme = {
        text = "ffffff";
        subtext = "999999";
        main = "000000";
        sidebar = "000000";
        player = "000000";
        card = "111111";
        shadow = "000000";
        selectedRow = "222222";
        button = "ffffff";
        buttonActive = "cccccc";
        buttonDisabled = "444444";
        tabActive = "222222";
        notification = "111111";
        notificationError = "ffffff";
        misc = "333333";
      };
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle
      ];
    };

  # ── shell / editors ───────────────────────────────────────────────────
  programs.micro = {
    enable = true;
    settings.colorscheme = "simple";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      use-package
      which-key
      vertico
      orderless
      marginalia
      consult
      embark
      embark-consult
      avy
      corfu
      cape
      kind-icon
      nix-mode
      powershell
      nasm-mode
      disaster
      x86-lookup
      magit
      envrc
      vterm
      pdf-tools
      mood-line
      dashboard
      org-roam
      org-noter
    ];
  };

  # ── packages ──────────────────────────────────────────────────────────
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

    # scripts
    (writeShellScriptBin "toggle-mic" ''
      ${wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      if ${wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
          ${libnotify}/bin/notify-send "Microphone" "DISABLED"
      else
          ${libnotify}/bin/notify-send "Microphone" "ENABLED"
      fi
    '')

    (writeShellScriptBin "wallpicker" ''
      WALL_DIR="$HOME/nixconfig/Wallpapers"
      TMP_FILE="/tmp/wall_picker_target"
      CACHE_FILE="$HOME/.cache/current_wallpaper"

      ${kitty}/bin/kitty --class "wall-picker" -e ${yazi}/bin/yazi "$WALL_DIR" --chooser-file="$TMP_FILE"

      if [ -s "$TMP_FILE" ]; then
          SELECTED=$(cat "$TMP_FILE")
          echo "$SELECTED" > "$CACHE_FILE"

          ${psmisc}/bin/killall swaybg 2>/dev/null || true
          ${swaybg}/bin/swaybg -i "$SELECTED" -m fill &

          rm "$TMP_FILE"
      fi
    '')
  ];

  programs.home-manager.enable = true;
}
