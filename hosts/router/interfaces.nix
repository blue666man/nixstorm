# Router interface configuration
# This file defines the network interface names for the router
# It can be included in the main configuration to override default values
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Define interface names for production router
  # Adjust these based on your actual hardware
  router.interfaces = {
    wan = "enp1s0"; # WAN interface (MAC: 20:7c:14:f8:34:a6)
    lan10g = "enp2s0"; # Primary LAN goes to big switch (MAC: 20:7c:14:f8:34:a7)
    lan2_5g-1 = "enp4s0"; # 2.5G LAN port 1 (MAC: 20:7c:14:f8:31:a8)
    lan2_5g-2 = "enp5s0"; # 2.5G LAN port 2 (MAC: 20:7c:14:f8:31:a9)
    lan2_5g-3 = "enp6s0"; # 2.5G LAN port 3 (MAC: 20:7c:14:f8:31:aa)
    lan2_5g-4 = "enp7s0"; # 2.5G LAN port 4 (MAC: 20:7c:14:f8:31:ab)
  };
}
