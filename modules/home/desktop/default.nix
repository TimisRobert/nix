{pkgs, ...}: {
  imports = [../.];

  home = {
    persistence."/persist/home/rob" = {
      directories = [
        ".local/share/Steam"
      ];
    };
    packages = [
      pkgs.gamemode
    ];
  };

  programs.obs-studio = {
    enable = true;
    plugins = [
      pkgs.obs-studio-plugins.wlrobs
    ];
  };
}
