{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # asm / debugging
    nasm
    asm-lsp
    gdb
    gef
    patchelf

    # reversing
    ghidra
    radare2
    imhex
    hexyl
    binwalk
    strace
    ltrace
    poppler-utils
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings.kali = {
      HostName = "172.16.211.10";
      User = "kali";
      IdentityFile = "~/.ssh/id_ed25519";
      StrictHostKeyChecking = "accept-new";
    };
  };

  xdg.configFile."asm-lsp/.asm-lsp.toml".text = ''
    [default_config]
    version = "${pkgs.asm-lsp.version}"
    assembler = "nasm"
    instruction_set = "x86/x86-64"

    [default_config.opts]
    compiler = "nasm"
    diagnostics = true
    default_diagnostics = true
  '';
}
