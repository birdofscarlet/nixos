{ ... }:

{
  imports = [
    ./dotfiles.nix
    ./theme.nix
    ./firefox.nix
    ./spotify.nix
    ./emacs.nix
    ./shell.nix
    ./packages.nix
    ./security.nix
    ./scripts.nix
  ];

  home.username = "cardinal";
  home.homeDirectory = "/home/cardinal";
  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.home-manager.enable = true;
}
