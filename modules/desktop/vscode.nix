# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:
let
  # Mixing unstable and stable channels
  # https://nixos.wiki/index.php?title=FAQ&oldid=3528#How_can_I_install_a_package_from_unstable_while_remaining_on_the_stable_channel.3F
  pkgs-unstable = (import inputs.nixpkgs-unstable) {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  # environment.systemPackages = [
    # https://github.com/NixOS/nixpkgs/issues/246509
    # env -u WAYLAND_DISPLAY code .
    # Setting "window.titleBarStyle" = "custom";works for me as a workaround.
    # ^ Ran `env -u WAYLAND_DISPLAY code .` once, then updated the settings via Preferences,
    #   then no longer need `env -u ...`
    # pkgs-unstable.vscode-fhs # vscode with FHS (File Hierarchy System) layout
    # pkgs.vscode-fhs # vscode with FHS (File Hierarchy System) layout
  # ];

  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        editorconfig.editorconfig
        esbenp.prettier-vscode
        firefox-devtools.vscode-firefox-debug
        github.copilot
        # github.copilot-chat
        github.vscode-github-actions
        # kevinrose.vsc-python-indent
        mechatroner.rainbow-csv
        # mgmcdermott.vscode-language-babel
        ms-python.black-formatter
        # ms-python.debugpy
        ms-python.isort
        ms-python.python
        ms-python.vscode-pylance
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        # ms-vscode-remote.remote-ssh-edit
        ms-vscode.makefile-tools
        # ms-vscode.remote-explorer
        naumovs.color-highlight
        # pflannery.vscode-versionlens
        # qwtel.sqlite-viewer
        redhat.vscode-yaml
        rust-lang.rust-analyzer
        # samuelcolvin.jinjahtml
        serayuzgur.crates
        # simonsiefke.svg-preview
        skellock.just
        streetsidesoftware.code-spell-checker
        # stuart.unique-window-colors
        tailscale.vscode-tailscale
        # thegtproject.hoverhex
        tomoki1207.pdf
        unifiedjs.vscode-mdx
        vadimcn.vscode-lldb
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          publisher = "Graphite";
          name = "gti-vscode";
          version = "0.5.2";
          sha256 = "sha256-IvXN0KhpZtqqyKrjtqcAQK31RLyPm+ZwwUcwAwtDMak=";
        }
      ];
    })

    # back to system packages

    pkgs-unstable.graphite-cli
  ];
}