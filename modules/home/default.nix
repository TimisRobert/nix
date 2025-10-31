{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];

  home = {
    username = "rob";
    homeDirectory = "/home/rob";
    stateVersion = "25.11";
    pointerCursor = {
      name = "Simp1e";
      package = pkgs.simp1e-cursors;
      size = 16;
      hyprcursor.enable = true;
    };
    sessionVariables = {
      WLR_RENDERER = "vulkan";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      ELIXIR_ERL_OPTIONS = "-kernel shell_history enabled";
      DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
    };
    sessionPath = [
      "$HOME/.local/bin"
    ];
    packages = [
      pkgs.docker-compose
      pkgs.kubectl
      pkgs.kubernetes-helm
      pkgs.duckdb
      pkgs.gping
      pkgs.duf
      pkgs.xh
      pkgs.doggo
      pkgs.yq
      pkgs.devenv
      pkgs.xdg-utils
      pkgs.wl-clipboard
      pkgs.grimblast
      pkgs.unzip
      pkgs.zip
      pkgs.ast-grep
    ];
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Simp1e";
      package = pkgs.simp1e-cursors;
      size = config.home.pointerCursor.size;
    };
  };

  xdg = {
    enable = true;
    userDirs = {
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
    };
    configFile = {
      "jjui/themes/kanagawa.toml".source = ../../assets/jjui_kanagawa.toml;
      "fish/themes/Kanagawa.theme".source = ../../assets/kanagawa.theme;
      nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nix/assets/astronvim";
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

      binds {
          drag_threshold = 10
      }
      bindm = $mainMod ALT, mouse:272, movewindow
      bindc = $mainMod ALT, mouse:272, togglefloating
    '';

    settings = {
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "rofi -show drun";
      "$fileManager" = "nnn";
      monitor = lib.mkDefault ",highres,auto,1";

      exec-once = [
        "hyprlock"
      ];

      ecosystem.no_update_news = true;

      general = {
        border_size = 1;
        gaps_out = 10;
        "col.active_border" = "0x76946AF1";
      };

      decoration = {
        rounding = 8;
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
        kb_options = "ctrl:nocaps";
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
        "$mainMod ALT, l, exec, hyprlock"

        "$mainMod, f, fullscreen,"

        "$mainMod, space, togglesplit,"
        "$mainMod, v, layoutmsg, preselect d"
        "$mainMod, b, layoutmsg, preselect r"

        "$mainMod, p, exec, grimblast copy area"

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

        # Microphone toggle
        ", F12, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtlSsh = 86400;
      defaultCacheTtl = 86400;
      pinentry = {
        package = pkgs.pinentry-qt;
      };
    };
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
          ignore_dbus_inhibit = false;
          lock_cmd = "pidof hyprlock || hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          before_sleep_cmd = "loginctl lock-session";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 18000;
            on-timeout = "systemctl suspend";
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
    mako = {
      enable = true;
      settings.default-timeout = 5000;
    };
  };

  programs = {
    gpg = {
      enable = true;
      scdaemonSettings = {
        disable-ccid = true;
      };
    };
    nix-index-database.comma.enable = true;
    k9s = {
      enable = true;
      settings = {
        k9s = {
          ui.skin = "kanagawa";
        };
      };
      skins = {
        kanagawa = ../../assets/k9s_kanagawa.yaml;
      };
    };
    bottom.enable = true;
    lsd.enable = true;
    bat.enable = true;
    jq.enable = true;
    nnn.enable = true;
    zathura.enable = true;
    zoxide.enable = true;
    fzf.enable = true;
    fd.enable = true;
    htop.enable = true;
    direnv.enable = true;
    ripgrep.enable = true;
    jujutsu = {
      enable = true;
      settings = {
        ui = {
          pager = "delta";
          diff-formatter = ":git";
          default-command = "log";
        };
        user = {
          name = "TimisRobert";
          email = "roberttimis@proton.me";
        };
        signing = {
          backend = "gpg";
          key = "06CEA7F23ADCA705";
        };
        diff.tool = "delta";
        git.sign-on-push = true;
      };
    };
    jjui = {
      enable = true;
      settings = {
        ui.theme = "kanagawa";
      };
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      extraPackages = [
        pkgs.gcc
        pkgs.inotify-tools
        pkgs.ghostscript
        pkgs.nodejs
        pkgs.helm-ls
        pkgs.dockerfile-language-server
        pkgs.shellcheck
        pkgs.pyright
        pkgs.ruff
        pkgs.terraform-ls
        pkgs.nodePackages."@astrojs/language-server"
        pkgs.zls
        pkgs.yaml-language-server
        pkgs.tailwindcss-language-server
        pkgs.emmet-ls
        pkgs.eslint
        pkgs.typescript-language-server
        pkgs.nodePackages.prettier
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
        pkgs.clang-tools
      ];
    };
    firefox = {
      enable = true;
      profiles.default.extraConfig = builtins.readFile ../../assets/user.js;
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        dark = true;
        navigate = true;
      };
    };
    git = {
      enable = true;
      settings = {
        user.name = "TimisRobert";
        user.email = "roberttimis@proton.me";
        fetch.prune = true;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
        rebase.updateRefs = true;
        credential.helper = "cache --timeout 604800";
        merge.conflictStyle = "zdiff3";
      };
      signing = {
        key = "06CEA7F23ADCA705";
        signByDefault = true;
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
    lazygit = {
      enable = true;
      settings = {
        disableStartupPopups = true;
        git.overrideGpg = true;
        git.paging.pager = "delta --dark --paging=never";
        git.paging.colorArg = "always";
      };
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        fish_config theme choose Kanagawa
      '';
    };
    hyprlock = {
      enable = true;
      settings = {
        background = {
          monitor = "";
          path = "screenshot";
          blur_passes = 1;
          blur_size = 7;
          noise = 1.17e-2;
        };

        # General
        general = {
          no_fade_in = false;
          grace = 0;
          disable_loading_bar = false;
        };

        # Input field
        input-field = {
          monitor = "";
          size = "250, 60";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "rgba(0, 0, 0, 0)";
          inner_color = "rgba(100, 114, 125, 0.4)";
          font_color = "rgb(200, 200, 200)";
          fade_on_empty = false;
          font_family = "Mononoki Mono";
          placeholder_text = ''<i><span foreground="##ffffff99">Input password...</span></i>'';
          fail_text = ''<i><span foreground="##ffffff99">$PAMFAIL</span></i>'';
          hide_input = false;
          position = "0, -225";
          halign = "center";
          valign = "center";
        };

        label = [
          # Time
          {
            monitor = "";
            text = ''cmd[update:1000] echo "<span>$(date +"%H:%M")</span>"'';
            color = "rgba(216, 222, 233, 0.70)";
            font_size = 130;
            font_family = "Mononoki Mono";
            position = "0, 240";
            halign = "center";
            valign = "center";
          }
          # Date
          {
            monitor = "";
            text = ''cmd[update:1000] echo -e "$(date +"%A, %d %B")"'';
            color = "rgba(216, 222, 233, 0.70)";
            font_size = 30;
            font_family = "Mononoki Mono";
            position = "0, 105";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
