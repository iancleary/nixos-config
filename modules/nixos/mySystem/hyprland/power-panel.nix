# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, pkgs, ... }:
let
  # Mixing unstable and stable channels
  # https://nixos.wiki/index.php?title=FAQ&oldid=3528#How_can_I_install_a_package_from_unstable_while_remaining_on_the_stable_channel.3F
  pkgs-unstable = (import inputs.nixpkgs-unstable) {
    system = "x86_64-linux";
  };
in
{
  # https://nixos.org/manual/nixos/stable/index.html#sec-customising-packages
  environment.systemPackages =
    let
      power-panel = with pkgs-unstable; rustPlatform.buildRustPackage rec {
        pname = "power-panel";
        version = "v1.0.0";

        src = fetchFromGitHub {
          owner = "iancleary";
          repo = pname;
          rev = version;
          hash = "sha256-DKjbxdvtmxSuy2I0/N2Ed0xAnLa1d5rn/XjCGPV3UHE=";
        };

        # https://nixos.wiki/wiki/Packaging/Quirks_and_Caveats
        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        buildInputs = with pkgs; [
          wayland
          gtk4
        ];

        cargoHash = "sha256-XOSOaL7j93xrX/IhZzhpP5NR7Q9MyG2BSFGpsMwe82Q=";

        meta = with lib; {
          description = "Rust GUI app to restart and shutdown a system";
          homepage = "https://github.com/iancleary/power-panel";
          license = licenses.mit;
          maintainers = with maintainers; [ iancleary ];
          platforms = [ "x86_64-linux" "aarch64-linux" ];
        };
      };
    in
    [
      power-panel
    ];

}
