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

  xdg.configFile."niri/host.kdl".source = ../niri/desktop.kdl;

  programs.noctalia.settings = {
    system.monitor.gpu_poll_seconds = 5.0;
    desktop_widgets.enabled = false;
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
