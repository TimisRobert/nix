{...}: {
  home.persistence."/persist/home/rob" = {
    directories = [
      ".local/share/Steam"
    ];
  };

  wayland.windowManager.sway.config.output."DP-1" = {
    mode = "5120x1440@239.761Hz";
  };
}
