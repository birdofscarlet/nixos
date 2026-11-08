# Firefox profile, userChrome, and the start page.
{ config, ... }:

let
  dots = ../../dotfiles/alicebox;
  repo = "${config.home.homeDirectory}/nixconfig";
in
{
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
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

  # live-editable, no rebuild needed
  home.file."startpage".source = config.lib.file.mkOutOfStoreSymlink "${repo}/startpage";
}
