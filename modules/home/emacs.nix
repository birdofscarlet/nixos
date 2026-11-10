{ config, pkgs, ... }:

let
  repo = "${config.home.homeDirectory}/nixconfig";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  programs.emacs = {
    enable = true;
    extraPackages =
      epkgs: with epkgs; [
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
        nasm-mode
        disaster
        x86-lookup
        rmsbolt
        nhexl-mode
        elf-mode
        magit
        envrc
        vterm
        pdf-tools
        mood-line
        dashboard
        org-roam
        org-noter
        consult-org-roam
        org-download
        org-modern
        olivetti
      ];
  };

  home.packages = with pkgs; [
    # language servers
    nixd
    nixfmt
    clang-tools
    basedpyright
  ];

  xdg.configFile = {
    "emacs/init.el".source = link "${repo}/emacs/init.el";
    "emacs/themes".source = link "${repo}/emacs/themes";
  };
}
