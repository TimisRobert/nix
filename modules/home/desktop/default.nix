{pkgs, ...}: {
  imports = [../.];

  xdg.configFile."pipewire/pipewire.conf.d/99-rnnoise.conf".text = builtins.toJSON {
    "context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "Noise Canceling source";
          "media.name" = "Noise Canceling source";

          "filter.graph" = {
            nodes = [
              {
                type = "ladspa";
                name = "rnnoise";
                plugin = "librnnoise_ladspa";
                label = "noise_suppressor_mono";
                control = {
                  "VAD Threshold (%)" = 95.0;
                  "VAD Grace Period (ms)" = 200;
                  "Retroactive VAD Grace (ms)" = 0;
                };
              }
            ];
          };

          "capture.props" = {
            "node.name" = "capture.rnnoise_source";
            "node.passive" = true;
            "audio.rate" = 48000;
            "target.object" = "alsa_input.usb-Kingston_HyperX_SoloCast-00.analog-stereo";
          };

          "playback.props" = {
            "node.name" = "rnnoise_source";
            "media.class" = "Audio/Source";
            "audio.rate" = 48000;
          };
        };
      }
    ];
  };

  programs.dank-material-shell.settings = {
    hyprlandOutputSettings."DP-4".colorManagement = "auto";
    bluetoothDevicePins.preferredDevice = ["80:99:E7:3D:09:9C"];
    desktopWidgetGridSettings."DP-4".enabled = true;
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
        positions."DP-4" = {
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
    ];
    sessionVariables = {
      PROTON_ENABLE_WAYLAND = "1";
      PROTON_ENABLE_HDR = "1";
      PROTON_DLSS_UPGRADE = "1";
    };
  };
}
