{pkgs, ...}: {
  imports = [../.];

  home = {
    sessionVariables = {
      PROTON_ENABLE_WAYLAND = "1";
      PROTON_USE_EAC_LINUX = "1";
    };
    packages = [
      pkgs.godot
      pkgs.blender
    ];
  };
}
