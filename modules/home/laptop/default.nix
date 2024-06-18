{lib, ...}: {
  imports = [../default.nix];

  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    "XF86MonBrightnessDown" = "exec light -U 5";
    "XF86MonBrightnessUp" = "exec light -A 5";
    "XF86AudioRaiseVolume" = "exec pamixer -i 5";
    "XF86AudioLowerVolume" = "exec pamixer -d 5";
    "XF86AudioMicMute" = "exec pamixer --source 59 -t";
    "XF86AudioMute" = "exec pamixer -t";
  };

  programs = {
    waybar = {
      enable = true;
      style = ''
        * {
          font-family: "Mononoki Nerd Font Mono";
          font-size: 12pt;
          font-weight: bold;
          border-radius: 0px;
          transition-property: background-color;
          transition-duration: 0.5s;
        }
        @keyframes blink_red {
          to {
            background-color: rgb(242, 143, 173);
            color: rgb(26, 24, 38);
          }
        }
        .warning, .critical, .urgent {
          animation-name: blink_red;
          animation-duration: 1s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
        window#waybar {
          background-color: transparent;
        }
        window > box {
          margin-left: 10px;
          margin-right: 10px;
          margin-top: 10px;
          background-color: rgb(30, 30, 46);
        }
        #mode {
          color: rgb(217, 224, 238);
        }
        #workspaces {
          padding-left: 0px;
          padding-right: 4px;
        }
        #workspaces button {
          padding-top: 4px;
          padding-bottom: 4px;
          padding-left: 2px;
          padding-right: 2px;
          background-color: rgb(16, 74, 94);
          color: rgb(26, 24, 38);
        }
        #workspaces button.focused {
          background-color: rgb(181, 232, 224);
          color: rgb(26, 24, 38);
        }
        #workspaces button.urgent {
          color: rgb(26, 24, 38);
        }
        #workspaces button:hover {
          background-color: rgb(248, 189, 150);
          color: rgb(26, 24, 38);
        }
        tooltip {
          background: rgb(48, 45, 65);
        }
        tooltip label {
          color: rgb(217, 224, 238);
        }
        #mode, #clock, #memory, #temperature, #cpu, #temperature, #backlight, #pulseaudio, #network, #battery {
          padding-left: 10px;
          padding-right: 10px;
        }
        #memory {
          color: rgb(181, 232, 224);
        }
        #cpu {
          color: rgb(245, 194, 231);
        }
        #clock {
          color: rgb(217, 224, 238);
        }
        #temperature {
          color: rgb(150, 205, 251);
        }
        #backlight {
          color: rgb(248, 189, 150);
        }
        #pulseaudio {
          color: rgb(245, 224, 220);
        }
        #network {
          color: #ABE9B3;
        }
        #network.disconnected {
          color: rgb(255, 255, 255);
        }
        #battery.charging, #battery.full, #battery.discharging {
          color: rgb(250, 227, 176);
        }
        #battery.critical:not(.charging) {
          color: rgb(242, 143, 173);
        }
        #tray {
          padding-right: 8px;
          padding-left: 10px;
        }
      '';
      settings = [
        {
          modules-left = ["sway/workspaces" "sway/mode"];
          modules-center = ["clock"];
          modules-right = [
            "pulseaudio"
            "backlight"
            "memory"
            "cpu"
            "network"
            "battery"
            "temperature"
            "tray"
          ];
          "sway/workspaces" = {"disable-scroll" = true;};
          "sway/mode" = {format = ''<span style="italic">{}</span>'';};
          "backlight" = {
            "device" = "intel_backlight";
            "on-scroll-up" = "light -A 5";
            "on-scroll-down" = "light -U 5";
            "format" = "{icon} {percent}%";
            "format-icons" = ["󰃝" "󰃞" "󰃟" "󰃠"];
          };
          "pulseaudio" = {
            "scroll-step" = 1;
            "format" = "{icon} {volume}%";
            "format-muted" = "󰖁 Muted";
            "format-icons" = {"default" = ["" "" ""];};
            "on-click" = "pamixer -t";
            "tooltip" = false;
          };
          "battery" = {
            "interval" = 10;
            "states" = {
              "warning" = 20;
              "critical" = 10;
            };
            "format" = "{icon} {capacity}%";
            "format-icons" = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            "format-full" = "{icon} {capacity}%";
            "format-charging" = "󰂄 {capacity}%";
            "tooltip" = false;
          };
          "clock" = {
            "interval" = 1;
            "format" = "{:%I:%M %p  %A %b %d}";
            "tooltip" = true;
            "tooltip-format" = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
          };
          "memory" = {
            "interval" = 1;
            "format" = "󰍛 {percentage}%";
            "states" = {"warning" = 85;};
          };
          "cpu" = {
            "interval" = 1;
            "format" = "󰻠 {usage}%";
          };
          "network" = {
            "interval" = 5;
            "format-wifi" = "󰖩 {essid} {signalStrength}%";
            "format-ethernet" = "󰀂 {ifname} {ipaddr}";
            "format-linked" = "󰖪 {essid} (No IP)";
            "format-disconnected" = "󰯡 Disconnected";
            "tooltip" = false;
          };
          "temperature" = {
            "tooltip" = false;
            "format" = " {temperatureC}°C";
          };
          "tray" = {
            "icon-size" = 15;
            "spacing" = 5;
          };
        }
      ];
    };
  };
}
