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
      pkgs.teams-for-linux
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

    settings = {
      "$mainMod" = "SUPER";
      "$terminal" = "alacritty";
      "$menu" = "wofi --show drun";
      "$fileManager" = "dolphin";
      monitor = ",preferred,auto,auto";

      general = {
        border_size = 1;
      };

      cursor = {
        inactive_timeout = 3;
        no_warps = true;
      };

      input = {
        kb_layout = "us";
        accel_profile = "flat";
      };

      bind = [
        "$mainMod, Return, exec, $terminal"
        "$mainMod, r, exec, $menu"

        "$mainMod, c, killactive,"

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
    alacritty = {
      enable = true;
      settings = {
        general.import = [../../assets/kanagawa_wave.toml];
        window = {opacity = 0.95;};
        font = {size = 12.0;};
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
    wofi = {
      enable = true;
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
        printscreen = "grim -g $(slurp -d) - | wl-copy -t image/png";
        screenshot = "grim -g $(slurp) $argv";
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
          modules-left = ["hyprland/workspaces" "hyprland/submap"];
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
          "hyprland/workspaces" = {"disable-scroll" = true;};
          "hyprland/submap" = {format = ''<span style="italic">{}</span>'';};
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
