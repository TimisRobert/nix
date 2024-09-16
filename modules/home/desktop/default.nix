{pkgs, ...}: {
  home.persistence."/persist/home/rob" = {
    directories = [
      ".local/share/Steam"
    ];
  };

  programs.obs-studio = {
    enable = true;
    plugins = [
      pkgs.obs-studio-plugins.wlrobs
    ];
  };
}
