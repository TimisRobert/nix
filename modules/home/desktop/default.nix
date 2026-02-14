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

  wayland.windowManager.hyprland.settings = {
    input.sensitivity = 0.5;
  };

  programs = {
    waybar = {
      enable = true;
      systemd.enable = true;
      style = builtins.readFile ../../../assets/waybar.css;
      settings = [
        {
          layer = "top";
          position = "top";
          reload_style_on_change = true;
          modules-left = ["hyprland/workspaces"];
          modules-center = ["clock"];
          modules-right = ["cpu" "memory" "temperature" "wireplumber" "wireplumber#source" "bluetooth" "network" "tray"];
          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              "active" = "";
              "default" = "";
              "empty" = "";
            };
            persistent-workspaces = {
              "*" = [1 2 3 4 5];
            };
          };
          clock = {
            format = "{:%I:%M:%S %p  %A %b %d}";
            interval = 1;
            tooltip-format = "<tt>{calendar}</tt>";
            calendar = {
              format = {
                today = "<span color='#fAfBfC'><b>{}</b></span>";
              };
            };
            actions = {
              on-click-right = "shift_down";
              on-click = "shift_up";
            };
          };
          network = {
            format-wifi = "";
            format-ethernet = "";
            format-disconnected = "";
            tooltip-format-disconnected = "Error";
            tooltip-format-wifi = "{essid} ({signalStrength}%) ";
            tooltip-format-ethernet = "{ifname} {ipaddr}";
            on-click = "kitty nmtui";
          };
          bluetooth = {
            format-on = "󰂯";
            format-off = "BT-off";
            format-disabled = "󰂲";
            format-connected-battery = "󰂯 {device_battery_percentage}%";
            format-alt = "󰂯 {device_alias}";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\n{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\n{device_address}\n{device_battery_percentage}%";
            on-click-right = "blueman-manager";
          };
          wireplumber = {
            scroll-step = 5;
            format = "{icon} {volume}%";
            format-muted = "󰖁 Muted";
            format-icons = {"default" = ["" "" ""];};
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            tooltip = false;
          };
          "wireplumber#source" = {
            node-type = "Audio/Source";
            format = "󰍬 {volume}%";
            format-muted = "󰍭";
            on-click-left = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            scroll-step = 5;
          };
          temperature = {
            critical-threshold = 80;
            format = " {temperatureC}°C";
            tooltip = false;
            # hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          };
          cpu = {
            format = "󰻠 {usage}%";
            tooltip = true;
          };
          memory = {
            format = " {percentage}%";
          };
          tray = {
            icon-size = 14;
            spacing = 10;
          };
        }
      ];
    };
  };
}
