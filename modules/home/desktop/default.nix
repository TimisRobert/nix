{pkgs, ...}: {
  imports = [../.];

  programs.dank-material-shell.settings = {
    hyprlandOutputSettings."DP-5".colorManagement = "auto";
    bluetoothDevicePins.preferredDevice = ["80:99:E7:3D:09:9C"];
    desktopWidgetGridSettings."DP-5".enabled = true;
    desktopWidgetInstances = [
      {
        id = "dw_1771197397994_r5e1u0fvl";
        widgetType = "systemMonitor";
        name = "System Monitor";
        enabled = true;
        config = {
          showHeader = true;
          transparency = 0.8;
          colorMode = "primary";
          customColor = "#ffffff";
          showCpu = true;
          showCpuGraph = true;
          showCpuTemp = true;
          showGpuTemp = true;
          gpuPciId = "10de:2c02";
          showMemory = true;
          showMemoryGraph = true;
          showNetwork = true;
          showNetworkGraph = true;
          showDisk = true;
          showTopProcesses = true;
          topProcessCount = 10;
          topProcessSortBy = "cpu";
          layoutMode = "auto";
          graphInterval = 300;
          displayPreferences = ["all"];
          showOnOverlay = false;
          showOnOverview = false;
          showOnOverviewOnly = true;
        };
        positions."DP-5" = {
          width = 440;
          height = 1320;
          x = 40;
          y = 80;
        };
      }
    ];
  };

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
