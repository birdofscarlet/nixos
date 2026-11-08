{ config, ... }:

let
  flake = "${config.home.homeDirectory}/nixconfig";
in
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      fastfetch
    '';

    functions = {
      fish_greeting = "";

      nrbd = ''
        pushd ${flake}
        nixos-rebuild build --flake .
        and nix store diff-closures (readlink -f /run/current-system) ./result
        popd
      '';

      nfmt = ''
        pushd ${flake}
        nix fmt
        popd
      '';
    };

    shellAbbrs = {
      # rebuild
      nrbs = "sudo nixos-rebuild switch --flake ${flake}";
      nrbb = "nixos-rebuild build --flake ${flake}";
      nrbt = "sudo nixos-rebuild test --flake ${flake}";
      nrbo = "sudo nixos-rebuild boot --flake ${flake}";
      nrbr = "sudo nixos-rebuild switch --rollback";
      ngen = "nixos-rebuild list-generations";

      # flake
      nfu = "nix flake update --flake ${flake}";
      nfc = "nix flake check ${flake}";
      nrepl = "nix repl --expr 'builtins.getFlake \"${flake}\"'";

      # packages
      nse = "nix search nixpkgs";
      nsh = {
        expansion = "nix shell nixpkgs#%";
        setCursor = true;
      };
      nrun = {
        expansion = "nix run nixpkgs#%";
        setCursor = true;
      };

      # store
      ngc = "sudo nix-collect-garbage --delete-older-than 7d";
      nopt = "nix store optimise";
    };
  };

  programs.micro = {
    enable = true;
    settings.colorscheme = "simple";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
