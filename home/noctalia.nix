{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  stylix.targets.noctalia.enable = false;

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      theme = {
        mode = "dark";
        source = "wallpaper";
        wallpaper_scheme = "m3-tonal-spot";
      };

      wallpaper = {
        enabled = true;
        fill_mode = "crop";
        directory = "/home/rob/pictures/wallpapers";
        default.path = "/home/rob/pictures/wallpapers/violet.png";
      };

      backdrop.enabled = false;

      shell = {
        font_family = "Inter";
        time_format = "{:%H:%M:%S}";
        date_format = "%A, %x";
        screenshot.directory = config.xdg.userDirs.pictures;
        polkit_agent = true;
        setup_wizard_enabled = false;
        settings_show_advanced = true;
        launch_apps_as_systemd_services = true;
        clipboard_enabled = true;
        clipboard_history_max_entries = 100;
        greeter_sync = {
          auto_sync = true;
          privilege_command = "pkexec";
        };
      };

      lockscreen = {
        enabled = true;
        fingerprint = true;
        allow_empty_password = true;
      };

      bar = {
        order = ["main"];
        main = {
          enabled = true;
          position = "top";
          auto_hide = false;
          reserve_space = true;
          thickness = 34;
          background_opacity = 0.9;
          radius = 0;
          margin_ends = 0;
          margin_edge = 0;
          padding = 4;
          widget_spacing = 4;
          scale = 1.1;
          capsule = true;
          capsule_fill = "surface_variant";
          capsule_opacity = 1.0;
          start = ["launcher" "workspaces" "active_window"];
          center = ["media" "clock" "weather"];
          end = [
            "tray"
            "privacy"
            "caffeine"
            "clipboard"
            "cpu-temp"
            "cpu"
            "memory"
            "notifications"
            "lock_keys"
            "network"
            "bluetooth"
            "volume"
            "input-volume"
            "brightness"
            "battery"
            "control-center"
          ];
        };
      };

      widget = {
        workspaces = {
          style = "regular";
          display = "none";
          enable_scroll = false;
        };
        active_window.title_scroll = "on_hover";
        clock = {
          format = "{:%H:%M:%S  %d/%m}";
          tooltip_format = "{:%A, %B %d, %Y}";
        };
        "cpu-temp" = {
          type = "sysmon";
          stat = "cpu_temp";
          display = "text";
        };
        cpu = {
          type = "sysmon";
          stat = "cpu_usage";
          display = "text";
        };
        memory = {
          type = "sysmon";
          stat = "ram_pct";
          display = "text";
        };
        privacy.hide_inactive = true;
        network.show_label = false;
        bluetooth.show_label = false;
        volume = {
          device = "output";
          enable_scroll = true;
          scroll_step = 5;
          show_label = false;
        };
        "input-volume" = {
          type = "volume";
          device = "input";
          enable_scroll = true;
          scroll_step = 5;
          show_label = false;
        };
        brightness = {
          enable_scroll = true;
          scroll_step = 5;
          show_label = false;
        };
        lock_keys = {
          display = "short";
          show_caps_lock = true;
          show_num_lock = false;
          show_scroll_lock = false;
          hide_when_off = true;
        };
      };

      control_center.shortcuts = [
        {type = "wifi";}
        {type = "bluetooth";}
        {type = "audio";}
        {type = "mic_mute";}
        {type = "nightlight";}
        {type = "dark_mode";}
      ];

      dock.enabled = false;

      location = {
        auto_locate = false;
        address = "Bergamo, Italy";
        latitude = 45.695;
        longitude = 9.67;
      };

      nightlight = {
        enabled = true;
        force = false;
        temperature_day = 6500;
        temperature_night = 5000;
      };

      weather = {
        enabled = true;
        refresh_minutes = 30;
        unit = "metric";
        effects = true;
      };

      notification = {
        enable_daemon = true;
        position = "top_right";
        layer = "top";
        background_opacity = 0.97;
      };

      system.monitor = {
        enabled = true;
        cpu_poll_seconds = 2.0;
        memory_poll_seconds = 2.0;
        network_poll_seconds = 3.0;
        disk_poll_seconds = 10.0;
      };

      idle = {
        pre_action_fade_seconds = 5.0;
        behavior = {
          lock = {
            enabled = true;
            timeout = 300;
            action = "lock";
          };
          "screen-off" = {
            enabled = true;
            timeout = 600;
            action = "screen_off";
          };
          suspend = {
            enabled = true;
            timeout = 3600;
            action = "lock_and_suspend";
          };
        };
      };
    };
  };
}
