{
  description = "My config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    neovim-plugins = {
      url = "github:iancleary/neovim-plugins-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixgl = {
    #   url = "github:guibou/nixGL";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    flake-hello-world.url = "github:iancleary/flake-hello-world";
    terminal-config.url = "github:iancleary/terminal-config";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , home-manager
    , agenix
    , neovim-plugins
      # , nixgl
    , nix-flatpak
    , flake-hello-world
    , terminal-config
    , hyprland
    , hyprland-contrib
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
        neovimPlugins = terminal-config.overlays.default;
        agenix = agenix.overlays.default;
        # nixgl = nixgl.overlays.default;
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
            agenix.nixosModules.default
            home-manager.nixosModules.default
            nix-flatpak.nixosModules.nix-flatpak
          ];
          specialArgs = { inherit inputs outputs; };

        in
        {
          framework = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./nixos/framework
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
    };
}
