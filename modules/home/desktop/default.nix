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

  # wayland.windowManager.sway.config.output."DP-1" = {
  #   mode = "5120x1440@239.761Hz";
  # };
}
