# list recipes
help:
  just --list

now := `date +"%Y-%m-%d_%H.%M.%S"`
hostname := `uname -n`

# echo hostname (uname -n)
echo:
  @echo "{{ hostname }}"

# Copy the nixos config in repo to /etc/nixos
update:
  bash config.sh "{{ hostname }}"

# Run `sudo nixos-rebuild switch`
switch:
  sudo nixos-rebuild switch

# Run `sudo nixos-rebuild switch --upgrade` to upgrade channels
upgrade:
  sudo nixos-rebuild switch --upgrade

# Reboot
reboot:
  sudo reboot now

version VERSION:
  @echo "{{ VERSION }}"

version-upgrade VERSION:
  sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-{{VERSION}}.tar.gz home-manager
  sudo nix-channel --update
  sudo  nix-channel --add https://channels.nixos.org/nixos-{{VERSION}} nixos
  nixos-rebuild switch --upgrade
