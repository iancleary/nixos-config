{
  description = "My config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-plugins = {
      url = "github:LongerHV/neovim-plugins-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-hello-world.url = "github:iancleary/flake-hello-world";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , home-manager
    , neovim-plugins
    , nixgl
    , flake-hello-world
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
    in
    rec {
      overlays = {
        default = import ./overlay/default.nix;
        unstable = final: prev: {
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
          inherit (nixpkgs-unstable.legacyPackages.${prev.system}) neovim-unwrapped;
        };
        neovimPlugins = neovim-plugins.overlays.default;
        nixgl = nixgl.overlays.default;
      };

      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;
          config.allowUnfree = true;
        }
      );

      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
        lint = nixpkgs.legacyPackages.${system}.callPackage ./shells/lint.nix { };
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages."${system}".nixpkgs-fmt);

      nixosConfigurations =
        let
          defaultModules = (builtins.attrValues nixosModules) ++ [
            # Flakes and Direnv
            ./modules/flakes.nix
            ./modules/nix-direnv.nix

            # Common
            ./modules/common/docker.nix
            ./modules/common/localBinInPath.nix
            ./modules/common/packages.nix
            ./modules/common/zsh.nix

            ./modules/networkmanager.nix
            ./modules/openssh.nix
            ./modules/garbage-collection.nix

            ./modules/tailscale.nix

            ./modules/unfree-allowed.nix

            # Locale and Timezone
            ./modules/localization/en_US.nix
            ./modules/timezone/America-Phoenix.nix
          ];
          specialArgs = { inherit inputs outputs; };

          virtualboxGuestModules = [
            ./modules/virtualbox/guest-enabled.nix
          ];

          gnomeDesktopModules = [
            ./modules/desktop # folder
            ./modules/desktop/gnome # folder
          ];

        in
        {
          framework = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = defaultModules ++ gnomeDesktopModules
              ++ [
              ./hardware-configuration.nix # hardware-configuration/framework.nix
              ./configuration.nix # hosts/framework.nix
              ./home/iancleary-gnome.nix
            ];
          };
          isoimage = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
              { isoImage.squashfsCompression = "gzip -Xcompression-level 1"; }
              ./nixos/iso
            ];
          };
          isoimage-server = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              {
                isoImage.squashfsCompression = "gzip -Xcompression-level 1";
                mySystem.user = "nixos";
              }
            ];
          };
        };

      homeConfigurations = {
        # Ubuntu WSL at home
        iancleary = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = (builtins.attrValues homeManagerModules) ++ [
            ./home-manager/work.nix
          ];
        };
      };
    };
}
