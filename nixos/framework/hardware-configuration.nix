# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };
  fileSystems = {
    "/" =
      {
        device = "rpool/safe/system/root";
        fsType = "zfs";
      };

    "/boot" =
      {
        device = "/dev/disk/by-uuid/CC98-279B";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };

    "/nix" =
      {
        device = "rpool/local/nix";
        fsType = "zfs";
      };

    "/var" =
      {
        device = "rpool/safe/system/var";
        fsType = "zfs";
      };

    "/home/iancleary" =
      {
        device = "rpool/safe/home/iancleary";
        fsType = "zfs";
      };
  };
  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
