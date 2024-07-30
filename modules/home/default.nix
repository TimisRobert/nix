{
  config,
  pkgs,
  lib,
  ...
}: {
  home = {
    username = "rob";
    homeDirectory = "/home/rob";
    stateVersion = "23.11";
    pointerCursor = {
      package = pkgs.simp1e-cursors;
      name = "Simp1e";
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      GTK_USE_PORTAL = "1";
      XDG_CURRENT_DESKTOP = "sway";
      EDITOR = "nvim";
      ELIXIR_ERL_OPTIONS = "-kernel shell_history enabled";
    };
    file.".config/nvim".source = let
      astronvimPath = ../../assets/astronvim;
    in
      config.lib.file.mkOutOfStoreSymlink "${astronvimPath}";
    persistence = {
      "/persist/home/rob" = {
        directories = [
          ".local/state/nvim"
          ".local/share/nvim"
          ".local/share/direnv"
          ".local/share/zoxide"
          ".local/share/fish"
          ".mozilla"
          ".ssh"
          ".aws"
        ];
        files = [];
        allowOther = true;
      };
    };
    packages = [
      pkgs.devenv
      pkgs.xdg-utils
      pkgs.pamixer
      pkgs.wl-clipboard
      pkgs.grim
      pkgs.slurp
      pkgs.swayimg
      pkgs.unzip
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

  wayland.windowManager.sway = {
    enable = true;
    extraConfig = ''
      for_window [class=".*"] inhibit_idle fullscreen
      for_window [app_id=".*"] inhibit_idle fullscreen
      seat * hide_cursor when-typing enable
    '';
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      output."*".bg = "${../../assets/bg.png} fill";
      window = {
        border = 1;
        titlebar = false;
      };
      gaps.inner = 10;
      bars = [{command = "waybar";}];
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_options = "caps:ctrl_modifier";
        };
      };
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
    swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 600;
          command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
          resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
        }
      ];
    };
    mako.enable = true;
  };

  programs = {
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
        pkgs.ruby-lsp
        pkgs.gnumake
        pkgs.gcc
        pkgs.nodePackages."@astrojs/language-server"
        pkgs.zls
        pkgs.yaml-language-server
        pkgs.tailwindcss-language-server
        pkgs.emmet-ls
        pkgs.vscode-langservers-extracted
        pkgs.typescript-language-server
        pkgs.prettierd
        pkgs.nodePackages.svelte-language-server
        pkgs.bash-language-server
        pkgs.shfmt
        pkgs.statix
        pkgs.alejandra
        pkgs.deadnix
        pkgs.nixd
        pkgs.lua-language-server
        pkgs.stylua
        pkgs.selene
        (pkgs.callPackage ./packages/lexical.nix {
          inherit lib;
          elixir = pkgs.elixir;
          beamPackages = pkgs.beamPackages;
          fetchFromGitHub = pkgs.fetchFromGitHub;
        })
      ];
    };
    firefox = {
      enable = true;
      package = pkgs.wrapFirefox (pkgs.firefox-unwrapped.override {pipewireSupport = true;}) {};
      profiles.default.extraConfig = builtins.readFile ../../assets/user.js;
    };
    git = {
      enable = true;
      userName = "TimisRobert";
      userEmail = "roberttimis@proton.me";
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
    };
    alacritty = {
      enable = true;
      settings = {
        import = [../../assets/kanagawa.toml];
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
    fzf = {
      enable = true;
    };
    lazygit = {
      enable = true;
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
      '';
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
    waybar = {
      enable = true;
      style = ../../assets/waybar.css;
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
