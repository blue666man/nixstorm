{
  config,
  lib,
  pkgs,
  ...
}: let
  # Script to monitor and disable looping ports
  loopMonitor = pkgs.writeScript "loop-monitor" ''
    #!${pkgs.bash}/bin/bash

    # Monitor kernel messages for loop detection
    PATTERN="^received packet on ([[:alnum:]]+) with own address as source$"
    INTERFACE_NAME=""
    ${pkgs.systemd}/bin/journalctl -f -n0 -k | while read line; do
      # The [[ ... =~ $PATTERN ]] structure attempts the match.
      # If successful (exit status 0), the captured text is stored in the global BASH_REMATCH array.
      if [[ "$line" =~ $PATTERN ]]; then
        # BASH_REMATCH[0] is the whole matched string.
        # BASH_REMATCH[1] is the content of the first capturing group (the interface name).
        INTERFACE_NAME="${BASH_REMATCH [1]}"
        # Don't bother checking
        echo "Loop detected on LAN interface: ${INTERFACE_NAME} , disabling port temporarily"
        ${pkgs.iproute2}/bin/ip link set ${INTERFACE_NAME} down
        sleep 60
        echo "Re-enabling ${INTERFACE_NAME}"
        ${pkgs.iproute2}/bin/ip link set ${INTERFACE_NAME} up
        ${pkgs.iproute2}/bin/ip link set ${INTERFACE_NAME} master br-lan
      fi
      INTERFACE_NAME=""
    done
  '';
in {
  # Create a systemd service to monitor for loops
  systemd.services.bridge-loop-monitor = {
    description = "Monitor and protect against bridge loops";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${loopMonitor}";
      Restart = "always";
      RestartSec = 5;
    };
  };

  # More aggressive STP settings
  systemd.network.netdevs."20-br-lan".bridgeConfig = lib.mkForce {
    STP = true;
    ForwardDelaySec = 2; # Faster convergence
    HelloTimeSec = 1; # More frequent BPDUs
    MaxAgeSec = 6; # Faster detection of topology changes
    Priority = 0; # Make this bridge the root bridge
  };

  # More strict configuration for lan2 port
  #systemd.network.networks."30-lan2".bridgeConfig = lib.mkForce {
  #  HairPin = false;
  #  FastLeave = true;
  #  Cost = 100; # Higher cost makes this port less preferred
  #  Priority = 32; # Valid range is 0-63
  #};

  # Add iptables rules to detect and log MAC spoofing
  networking.nftables.ruleset = lib.mkAfter ''
    table bridge filter {
      chain input {
        type filter hook input priority -200; policy accept;

        # Log packets with bridge's own MAC as source
        ether saddr 6e:a3:1e:6b:32:6b log prefix "LOOP-DETECTED: " counter drop
      }
    }
  '';
}
