{...}: {
  imports = [../.];

  home = {
    persistence."/persist/home/rob" = {
      directories = [
        ".local/share/Steam"
      ];
    };
    sessionVariables = {
      PROTON_ENABLE_WAYLAND = "1";
      PROTON_USE_EAC_LINUX = "1";
    };
  };
}
