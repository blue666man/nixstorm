{
  config,
  lib,
  pkgs,
  ...
}: let
  netConfig = config.router.network;
  network = "${netConfig.prefix}.0/${toString netConfig.cidr}";
in {
  # Proton VPN using Wireguard
  # Refer to:  https://wiki.nixos.org/wiki/WireGuard
}
