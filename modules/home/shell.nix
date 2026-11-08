{ ... }:

{
  programs.micro = {
    enable = true;
    settings.colorscheme = "simple";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
