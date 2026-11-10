{ ... }:
{
  # sysctl
  boot.kernel.sysctl = {
    "kernel.kexec_load_disabled" = 1;
    "kernel.sysrq" = 176;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
  };

  # access
  nix.settings.allowed-users = [ "@wheel" ];
  security.sudo.execWheelOnly = true;

  # tmp
  boot.tmp.cleanOnBoot = true;
}
