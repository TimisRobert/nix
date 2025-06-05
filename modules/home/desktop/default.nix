{pkgs, ...}: {
  imports = [../.];

  home = {
    persistence."/persist/home/rob" = {
      directories = [
        ".local/share/Steam"
      ];
    };
    sessionVariables = {
      PROTON_ENABLE_HDR = "1";
      PROTON_ENABLE_WAYLAND = "1";
    };
    packages = [
      pkgs.gamemode
    ];
  };

  wayland.windowManager.hyprland = {
    settings = {
      monitor = ",highres,auto,1,bitdepth,10";
      render = {
        cm_fs_passthrough = 1;
      };
      experimental = {
        xx_color_management_v4 = true;
      };
    };
  };
}
