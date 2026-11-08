{ config, pkgs, ... }:

let
  dots = ../../dotfiles/common;
  repo = "${config.home.homeDirectory}/nixconfig";
  startpage = "file://${config.home.homeDirectory}/startpage/index.html";
in
{
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    package = pkgs.firefox.override {
      extraPrefs = ''
        try {
          const { AboutNewTab } = ChromeUtils.importESModule("resource:///modules/AboutNewTab.sys.mjs");
          AboutNewTab.newTabURL = "${startpage}";
        } catch (e) { Components.utils.reportError(e); }
      '';
    };
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
        "browser.startup.page" = 1;
        "browser.startup.homepage" = startpage;
        "browser.newtabpage.enabled" = false;
      };
      userChrome = builtins.readFile "${dots}/firefox/userChrome.css";
    };
  };

  home.file."startpage".source = config.lib.file.mkOutOfStoreSymlink "${repo}/startpage";
}
