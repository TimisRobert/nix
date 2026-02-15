{pkgs, ...}: {
  imports = [../.];

  home = {
    packages = [
      pkgs.godot
      pkgs.blender
      pkgs.protonup-ng
    ];
    sessionVariables = {
      PROTON_ENABLE_WAYLAND = "1";
      PROTON_ENABLE_HDR = "1";
      PROTON_DLSS_UPGRADE = "1";
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
  };
}
