{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # school
    xournalpp
    pandoc
    texliveMedium
    hunspell
    hunspellDicts.en_US
  ];
}
