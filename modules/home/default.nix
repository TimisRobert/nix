{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
    inputs.nix-index-database.hmModules.nix-index
  ];

  home = {
    username = "rob";
    homeDirectory = "/home/rob";
    stateVersion = "25.05";
    pointerCursor = {
      package = pkgs.simp1e-cursors;
      name = "Simp1e";
    };
    sessionVariables = {
      WLR_RENDERER = "vulkan";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      ELIXIR_ERL_OPTIONS = "-kernel shell_history enabled";
    };
    file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nix/assets/astronvim";
    file.".config/fish/themes/Kanagawa.theme".source = ../../assets/kanagawa.theme;
    persistence = {
      "/persist/home/rob" = {
        directories = [
          ".local/state/nvim"
          ".local/share/nvim"
          ".local/share/direnv"
          ".local/share/zoxide"
          ".local/share/fish"
          ".config/discord"
          ".config/teams-for-linux"
          ".config/obs-studio"
          ".mozilla"
          ".ssh"
          ".aws"
        ];
        files = [];
        allowOther = true;
      };
    };
    packages = [
      pkgs.riffdiff
      pkgs.devenv
      pkgs.xdg-utils
      pkgs.pamixer
      pkgs.wl-clipboard
      pkgs.grim
      pkgs.slurp
      pkgs.unzip
      pkgs.zip
      pkgs.lsd
    ];
  };

  xdg = {
    enable = true;
    userDirs = {
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
    };
    mimeApps.enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = false;

    extraConfig = ''
      bind = $mainMod, r, submap, resize
      submap=resize
      binde = , h, resizeactive, -10 0
      binde = , l, resizeactive, 10 0
      binde = , k, resizeactive, 0 -10
      binde = , j, resizeactive, 0 10
      bind = , escape, submap, reset
      submap=reset
    '';

    settings = {
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "rofi -show drun";
      "$fileManager" = "dolphin";
      monitor = ",preferred,auto,auto";

      general = {
        border_size = 1;
        gaps_out = 10;
        "col.active_border" = "0x76946AF1";
      };

      decoration = {
        rounding = 4;
      };

      layerrule = [
        "noanim,selection"
      ];

      animations = {
        enabled = true;
        bezier = ["fluid, 0.15, 0.85, 0.25, 1" "snappy, 0.3, 1, 0.4, 1"];
        animation = [
          "windows, 1, 3, fluid, popin 5%"
          "windowsOut, 1, 2.5, snappy"
          "fade, 1, 4, snappy"
          "workspaces, 1, 1.7, snappy, slide"
          "specialWorkspace, 1, 4, fluid, slidefadevert -35%"
          "layers, 1, 2, snappy, popin 70%"
        ];
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      cursor = {
        inactive_timeout = 5;
        persistent_warps = true;
      };

      input = {
        kb_layout = "us";
        accel_profile = "flat";
      };

      dwindle = {
        force_split = 2;
        preserve_split = true;
      };

      bind = [
        "$mainMod, return, exec, $terminal"
        "$mainMod, d, exec, $menu"

        "$mainMod, c, killactive,"

        "$mainMod, f, fullscreen,"

        "$mainMod, space, togglesplit,"
        "$mainMod, v, layoutmsg, preselect d"
        "$mainMod, b, layoutmsg, preselect r"

        # Move focus with mainMod + arrow keys
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        # Move window
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, l, movewindow, r"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, j, movewindow, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
      ];
    };
  };

  services = {
    gammastep = {
      enable = true;
      provider = "manual";
      temperature = {
        day = 6500;
        night = 4500;
      };
      latitude = 45.30;
      longitude = 9.5;
    };
    hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
    hyprpaper = {
      enable = true;
      settings = {
        preload = ["/home/rob/projects/nix/assets/bg.png"];
        wallpaper = [
          ",/home/rob/projects/nix/assets/bg.png"
        ];
      };
    };
    mako.enable = true;
  };

  programs = {
    nix-index = {
      enable = true;
    };
    nix-index-database = {
      comma.enable = true;
    };
    nnn = {
      enable = true;
    };
    zathura = {
      enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      extraPackages = [
        pkgs.nodejs
        pkgs.ripgrep
        pkgs.bottom
        pkgs.python312Packages.python-lsp-server
        pkgs.black
        pkgs.terraform-ls
        pkgs.gnumake
        pkgs.gcc
        pkgs.nodePackages."@astrojs/language-server"
        pkgs.zls
        pkgs.yaml-language-server
        pkgs.tailwindcss-language-server
        pkgs.emmet-ls
        pkgs.vscode-langservers-extracted
        pkgs.vtsls
        pkgs.prettierd
        pkgs.svelte-language-server
        pkgs.bash-language-server
        pkgs.shfmt
        pkgs.statix
        pkgs.alejandra
        pkgs.deadnix
        pkgs.nixd
        pkgs.lua-language-server
        pkgs.stylua
        pkgs.selene
        pkgs.rust-analyzer
        pkgs.lexical
        pkgs.clang-tools
      ];
    };
    firefox = {
      enable = true;
      profiles.default.extraConfig = builtins.readFile ../../assets/user.js;
    };
    git = {
      enable = true;
      userName = "TimisRobert";
      userEmail = "roberttimis@proton.me";
      signing = {
        format = "ssh";
        signByDefault = true;
      };
      extraConfig = {
        user.signingKey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        fetch.prune = true;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
        rebase.updateRefs = true;
        credential.helper = "cache --timeout 604800";
      };
    };
    kitty = {
      enable = true;
      themeFile = "kanagawa";
      font = {
        name = "Mononoki Mono";
        size = 12;
      };
      settings = {
        background_opacity = 0.95;
        modify_font = "cell_height +1px";
      };
    };
    zoxide = {
      enable = true;
    };
    starship = {
      enable = true;
      enableTransience = true;
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
        add_newline = false;
        directory = {
          truncation_length = 0;
        };
      };
    };
    rofi = {
      enable = true;
      theme = ../../assets/rofi.rasi;
    };
    fzf = {
      enable = true;
    };
    lazygit = {
      enable = true;
      settings = {
        disableStartupPopups = true;
      };
    };
    direnv = {
      enable = true;
    };
    ripgrep = {
      enable = true;
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        fish_config theme choose Kanagawa
      '';
      shellAliases = {
        ls = "lsd";
        lg = "lazygit";
        diff = "riff";
      };
      plugins = [
        {
          name = "plugin-git";
          src =
            pkgs.fishPlugins.plugin-git.src;
        }
      ];
      functions = {
        printscreen = "grim -g $(slurp -d -w 0) - | wl-copy -t image/png";
        screenshot = "grim -g $(slurp -w 0) $argv";
      };
    };
    hyprlock = {
      enable = true;
    };
    waybar = {
      enable = true;
      systemd.enable = true;
      style = ../../assets/waybar.css;
      settings = [
        {
          layer = "top";
          position = "top";
          reload_style_on_change = true;
          modules-left = ["hyprland/workspaces"];
          modules-center = ["clock"];
          modules-right = ["group/expand" "pulseaudio" "bluetooth" "network" "battery" "tray"];
          "hyprland/workspaces" = {
            "format" = "{icon}";
            "format-icons" = {
              "active" = "";
              "default" = "";
              "empty" = "";
            };
            persistent-workspaces = {
              "*" = [1 2 3 4 5];
            };
          };
          "clock" = {
            "format" = "{:%I:%M:%S %p  %A %b %d}";
            "interval" = 1;
            "tooltip-format" = "<tt>{calendar}</tt>";
            "calendar" = {
              "format" = {
                "today" = "<span color='#fAfBfC'><b>{}</b></span>";
              };
            };
            "actions" = {
              "on-click-right" = "shift_down";
              "on-click" = "shift_up";
            };
          };
          "network" = {
            "format-wifi" = "";
            "format-ethernet" = "";
            "format-disconnected" = "";
            "tooltip-format-disconnected" = "Error";
            "tooltip-format-wifi" = "{essid} ({signalStrength}%) ";
            "tooltip-format-ethernet" = "{ifname} {ipaddr}";
            "on-click" = "kitty nmtui";
          };
          "bluetooth" = {
            "format-on" = "󰂯";
            "format-off" = "BT-off";
            "format-disabled" = "󰂲";
            "format-connected-battery" = "{device_battery_percentage}% 󰂯";
            "format-alt" = "{device_alias} 󰂯";
            "tooltip-format" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            "tooltip-format-enumerate-connected" = "{device_alias}\n{device_address}";
            "tooltip-format-enumerate-connected-battery" = "{device_alias}\n{device_address}\n{device_battery_percentage}%";
            "on-click-right" = "blueman-manager";
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
            "interval" = 30;
            "states" = {
              "good" = 95;
              "warning" = 30;
              "critical" = 20;
            };
            "format" = "{capacity}% {icon}";
            "format-charging" = "{capacity}% 󰂄";
            "format-plugged" = "{capacity}% 󰂄 ";
            "format-alt" = "{time} {icon}";
            "format-icons" = ["󰁻" "󰁼" "󰁾" "󰂀" "󰂂" "󰁹"];
          };
          "custom/expand" = {
            "format" = "";
            "tooltip" = false;
          };
          "custom/endpoint" = {
            "format" = "|";
            "tooltip" = false;
          };
          "group/expand" = {
            "orientation" = "horizontal";
            "drawer" = {
              "transition-duration" = 600;
              "transition-to-left" = true;
              "click-to-reveal" = true;
            };
            "modules" = ["custom/expand" "custom/colorpicker" "cpu" "memory" "temperature" "custom/endpoint"];
          };
          cpu = {
            format = "󰻠";
            tooltip = true;
          };
          memory = {
            format = "";
          };
          temperature = {
            critical-threshold = 80;
            format = "";
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
