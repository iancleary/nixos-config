{ inputs, outputs, config, lib, pkgs, ... }:

let
  cfg = config.mySystem;
in
{
  imports = [
    ./gaming.nix
    ./gnome.nix
    ./flatpak.nix
    ./kde.nix
    ./tailscale.nix
    ./user.nix
    ./virt.nix
    ./hyprland
  ];

  options.mySystem = with lib; { };

  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    boot.tmp.useTmpfs = lib.mkDefault true;
    zramSwap.enable = lib.mkDefault true;

    time.timeZone = lib.mkDefault "America/Phoenix";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    console = {
      font = lib.mkDefault "meslo-lgs-nf";
      keyMap = lib.mkDefault "us";
    };

    nixpkgs.overlays = builtins.attrValues outputs.overlays;
    nixpkgs.config.allowUnfree = true;
    nix = {
      package = pkgs.nix;

      ## enables flakes
      # experimental-features = "nix-command flakes";
      ## nix-direnv (# https://github.com/nix-community/nix-direnv#via-home-manager)
      # keep-outputs = true;
      # keep-derivations = true; # keep build derivations
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      '';
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      gc = {
        automatic = lib.mkDefault true;
        options = lib.mkDefault "--delete-older-than 14d";
        dates = lib.mkDefault "weekly";
      };
      settings = {
        auto-optimise-store = lib.mkDefault true;
        # substituters = map (x: substituters.${x}.url) cfg.nix.substituters;
        # trusted-public-keys = map (x: substituters.${x}.key) cfg.nix.substituters;
      };
    };

    services.openssh = with lib; {
      enable = mkDefault false;
      settings = {
        PasswordAuthentication = mkDefault false;
        KbdInteractiveAuthentication = mkDefault false;
        PermitRootLogin = mkDefault "no";
      };
    };


    environment = {
      systemPackages = with pkgs; [
        agenix
        git
        dnsutils
        pciutils
      ];
      # to help zsh completions
      pathsToLink = [ "/share/zsh" ];
      # https://nixos.wiki/wiki/Command_Shell
      # Many programs look at /etc/shells to determine if a user is a "normal" user and not a "system" user.
      # Therefore it is recommended to add the user shells to this list.
      # To add a shell to /etc/shells use the following line in your config:
      shells = [ pkgs.zsh ];
    };



    # https://nixos.wiki/wiki/Command_Shell
    users.defaultUserShell = pkgs.zsh;

    ########
    ## When using SSH, Windows Terminal, or VS Code with a shared directory
    ## You need the fonts installed on the host machine, not the nix target
    ##
    ## To install them on your local machine
    ## https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k
    ########
    fonts = {
      # Install font (on the nix target, see above for WSL or virtual machine)
      # tl;dr you install fonts on the machine that is rendering the fonts
      packages = with pkgs; [
        meslo-lgs-nf
      ];
      # https://github.com/nix-community/home-manager/issues/605#issuecomment-753667922
      fontconfig = {
        enable = true;
        # https://nixos.wiki/wiki/Fonts
        defaultFonts = {
          serif = [ "meslo-lgs-nf" ];
          sansSerif = [ "meslo-lgs-nf" ];
          monospace = [ "meslo-lgs-nf" ];
        };
      };
    };
  };
}
