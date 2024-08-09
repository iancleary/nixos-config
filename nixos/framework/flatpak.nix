{ _, ... }:

{
  mySystem.flatpak = {
    enable = true;
    packages = [
      "im.riot.Riot"
      "com.rafaelmardojai.Blanket" # Background noise
      "re.sonny.Junction" # Web browser chooser (select it as a default browser)
      "com.github.tchx84.Flatseal" # Manage Flatpak permissions
      "org.gabmus.whatip" # IP address
      # Productivity
      "io.github.seadve.Kooha" # Screen recording
      "com.github.junrrein.PDFSlicer" # PDF splitter
      "org.kde.okular" # PDF reader/editor
      "org.libreoffice.LibreOffice" # Office suite
      "app/org.videolan.VLC/x86_64/stable" # Video player
      "nl.hjdskes.gcolor3" # Color picker
      # "ca.desrt.dconf-editor"
      "md.obsidian.Obsidian"
      "com.bitwarden.desktop"

      # Todoist
      # "com.todoist.Todoist" # electron, no thanks
      "io.github.alainm23.planify"
    ];
    update.auto = {
      enable = true;
      onCalendar = "weekly";
      # https://github.com/gmodena/nix-flatpak?tab=readme-ov-file#updates
    };
    # enforce declarative installations
    uninstallUnmanaged = true;
  };
}
