# Disko Configuration for home router using NixOS and Disko:
#
## Disk /dev/nvme0n1: 238.47 GiB, 256060514304 bytes, 500118192 sectors
## Disk model: YSO256GTLCW-E3C-2
## Units: sectors of 1 * 512 = 512 bytes
## Sector size (logical/physical): 512 bytes / 512 bytes
## I/O size (minimum/optimal): 512 bytes / 512 bytes
## Disklabel type: dos
## Disk identifier: 0x61486328
{
  config,
  lib,
  pkgs,
  ...
}: {
  disko.devices = {
    disk = {
      nvme0n1 = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                  "nofail"
                ];
              };
            };

            proxyCache = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/proxyCache";
              };
            };

            encryptedSwap = {
              size = "16G";
              content = {
                type = "swap";
                discardPolicy = "both";
                randomEncryption = true;
                priority = 100; # prefer to encrypt as long as we have space for it
              };
            };

            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
