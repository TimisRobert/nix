set -e

sudo su

DISK=/dev/sda

parted -s $DISK -- mklabel gpt

parted -s $DISK -- mkpart ESP fat32 1MiB 512MiB
parted -s $DISK -- set 1 boot on

parted -s $DISK -- mkpart nix 512MiB 100%

# /boot partition for EFI
mkfs.vfat /dev/sda1

# /nix partition
mkfs.ext4 /dev/sda2

# Mount your root file system
mount -t tmpfs none /mnt

# Create directories
mkdir -p /mnt/{boot,nix,etc/nixos,var/log}

# Mount /boot and /nix
mount /dev/sda1 /mnt/boot
mount /dev/sda2 /mnt/nix

# Create a directory for persistent directories
mkdir -p /mnt/nix/persist/{etc/nixos,var/log}

nixos-generate-config --root /mnt

echo '
{ pkgs, config, inputs, modulesPath, lib, hostName, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.zsh.enable = true;
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users = {
      root = {
        initialHashedPassword =
          "$6$8vuSs91NJ39SZy.b$b2ujBj2.iq9pPpZD0XL4yS7oJ0ODG2eGfGf7YVLt5OLkthe1tgKyEYPzRDTNO9J0Om1mVPIdpCWE7MIwKspDa/";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvR28lwcOKIk7VRo/bXzxQGnA5evdsGcNZCy3BA6DDR rob@RobertTimis"
        ];
      };
    };
  };

  system.stateVersion = "23.05";
}
' > /mnt/etc/nixos/configuration.nix

echo '
{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/ESP";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-partlabel/nix";
    fsType = "ext4";
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
' > /mnt/etc/nixos/hardware-configuration.nix

exit

sudo nixos-install --no-root-passwd
sudo umount -l /mnt
sudo poweroff
