# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
    ./hardware-configuration.nix
    ./networking.nix
    ./vm-variant.nix
    ./flatpak.nix
  ];

  mySystem = {
    gnome.enable = false;
    kde.enable = false;
    hyprland.enable = true;
    gaming.enable = true;
    tailscale = {
      enable = true;
      unstable = true;
    };
    vmHost = false;
    dockerHost = true;
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
    # nix.substituters = [ "nasgul" ];
  };

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot"; # ← use the same mount point here.
      };
      grub = {
        efiSupport = true;
        #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
        device = "nodev";
      };
    };
    # https://nixos.wiki/wiki/Linux_kernel
    # boot.kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    # kernelParams = [
    #   # For Power consumption
    #  # https://kvark.github.io/linux/framework/2021/10/17/framework-nixos.html
    #   "mem_sleep_default=deep"
    #   # For Power consumption
    #   # https://community.frame.work/t/linux-battery-life-tuning/6665/156
    #   "nvme.noacpi=1"
    #   # Workaround iGPU hangs
    #   # https://discourse.nixos.org/t/intel-12th-gen-igpu-freezes/21768/4
    #   "i915.enable_psr=1"
    # ];

    # # Fix TRRS headphones missing a mic
    # # https://community.frame.work/t/headset-microphone-on-linux/12387/3
    # extraModprobeConfig = ''
    #   options snd-hda-intel model=dell-headset-multi
    # '';
  };

  # testing fwupd on framework 11th gen intel
  # https://knowledgebase.frame.work/en_us/framework-laptop-bios-releases-S1dMQt6F#Linux_BIOS
  # https://nixos.wiki/wiki/Fwupd
  services = {
    fwupd = {
      enable = true;
    };
    # Enable thermal data
    thermald.enable = true;

    # Enable fingerprint support
    fprintd.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable sound with pipewire.
    pipewire = {
      enable = true;
      alsa.enable = true;
      # alsamixer: https://nixos.wiki/wiki/ALSA
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };

  # Enable sound with pipewire.
  sound.enable = true;
  security.rtkit.enable = true;



  hardware = {
    # https://nixos.wiki/wiki/Bluetooth#Enabling_A2DP_Sink
    bluetooth = {
      enable = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };

    # Enable sound with pipewire.
    pulseaudio.enable = false;
    # extra opengl packages for intel graphics
    opengl.extraPackages = with pkgs; [
      mesa_drivers
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  powerManagement = {
    # https://community.frame.work/t/nixos-on-the-framework-blog-review/3835/10?u=ian_cleary
    # https://gist.github.com/digitalknk/ee0379c1cd4597463c31a323ea5882a5
    # Some of the config was pulled from the above gist
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = lib.mkDefault "ondemand";
  };

  networking = {
    hostName = "framework";
    hostId = "8425e349"; # zfs
  };


  # stay awake on lid close
  # services.logind.lidSwitchExternalPower = "ignore";


  # Custom udev rules
  services.udev.extraRules = ''
    # Fix headphone noise when on powersave
    # https://community.frame.work/t/headphone-jack-intermittent-noise/5246/55
    SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0xa0e0", ATTR{power/control}="on"
    # Ethernet expansion card support
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", ATTR{power/autosuspend}="20"
  '';



  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
