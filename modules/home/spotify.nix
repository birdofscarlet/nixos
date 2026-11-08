{ inputs, pkgs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
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
}
