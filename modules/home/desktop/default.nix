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
}
