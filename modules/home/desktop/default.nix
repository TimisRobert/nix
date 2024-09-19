{pkgs, ...}: {
  home.persistence."/persist/home/rob" = {
    directories = [
      ".local/share/Steam"
    ];
  };

  home.packages = [
    pkgs.gamemode
  ];

  programs.obs-studio = {
    enable = true;
    plugins = [
      pkgs.obs-studio-plugins.wlrobs
    ];
  };
}
