# Tools for HTB / reversing / pwn on the host. Heavier offensive tooling stays in the Kali VM.
{ pkgs, ... }:

let
  pyEnv = pkgs.python3.withPackages (
    ps: with ps; [
      pwntools # also provides ROPgadget and checksec
      requests
      scapy
      impacket
      ipython
    ]
  );
in
{
  home.packages = with pkgs; [
    # writing exploits and own tools
    pyEnv
    nasm
    asm-lsp
    gdb
    gef # `gef ./bin` = gdb with gef loaded; plain gdb stays clean for Emacs
    patchelf
    pwninit
    one_gadget

    # reversing
    ghidra
    radare2
    imhex
    hexyl
    binwalk
    strace
    ltrace
    poppler-utils # pdftotext, used by Emacs x86-lookup

    # network / web
    openvpn # HTB: sudo openvpn ~/htb/lab.ovpn
    nmap
    netcat-openbsd
    socat
    ffuf
    gobuster
    feroxbuster
    whatweb
    sqlmap
    burpsuite
    john
    exiftool
  ];

  # global asm-lsp config: NASM syntax, x86-64. Per-project .asm-lsp.toml overrides it.
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
