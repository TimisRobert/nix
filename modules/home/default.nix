{ config
, pkgs
, lib
, inputs
, ...
}: {
  imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];

  home = {
    username = "rob";
    homeDirectory = "/home/rob";
    stateVersion = "23.05";
    pointerCursor = {
      package = pkgs.simp1e-cursors;
      name = "Simp1e";
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      EDITOR = "nvim";
    };
    persistence = {
      "/nix/persist/home/rob" = {
        directories = [
          "projects"
          "documents"
          ".cache/nix"
          ".config/qmk"
          ".config/chromium"
          ".config/containers"
          ".config/Bitwarden CLI"
          ".local/share/nvim"
          ".local/share/direnv"
          ".local/state/nvim"
          ".local/share/Steam"
          ".local/share/zoxide"
          ".local/share/fish"
          ".ssh"
          ".aws"
          ".mix"
        ];
        files = [
        ];
        allowOther = true;
      };
    };
    packages = [
      # Zig
      pkgs.zls
      # Yaml
      pkgs.yaml-language-server
      # HTML CSS
      pkgs.nodePackages."@tailwindcss/language-server"
      pkgs.emmet-ls
      pkgs.vscode-langservers-extracted
      # Typescript
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.eslint_d
      pkgs.prettierd
      # Svelte
      pkgs.nodePackages.svelte-language-server
      # Bash
      pkgs.nodePackages.bash-language-server
      pkgs.shellcheck
      pkgs.shfmt
      # Nix
      pkgs.statix
      pkgs.alejandra
      pkgs.deadnix
      pkgs.rnix-lsp
      # Lua
      pkgs.lua-language-server
      pkgs.stylua
      pkgs.selene
      # Elixir
      pkgs.beamPackages.elixir-ls
      # System
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
    configFile = {
      astronvim = {
        source = ../../assets/astronvim;
      };
      nvim = {
        source = inputs.astronvim;
      };
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
      output = {
        "*".bg = "${config.home.homeDirectory}/documents/images/bg.png fill";
      };
      window = {
        border = 1;
        titlebar = false;
      };
      gaps.inner = 10;
      bars = [{ command = "waybar"; }];
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_options = "caps:ctrl_modifier";
          # xkb_variant = "colemak";
        };
      };
      keybindings = lib.mkOptionDefault {
        "XF86MonBrightnessDown" = "exec light -U 5";
        "XF86MonBrightnessUp" = "exec light -A 5";
        "XF86AudioRaiseVolume" = "exec pamixer -i 5";
        "XF86AudioLowerVolume" = "exec pamixer -d 5";
        "XF86AudioMicMute" = "exec pamixer --source 67 -t";
        "XF86AudioMute" = "exec pamixer -t";
      };
    };
  };

  services = {
    pueue = {
      enable = true;
      settings = {
        shared = { };
      };
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
    neovim = {
      enable = true;
      defaultEditor = true;

      vimAlias = true;
      withPython3 = true;
      withNodeJs = true;
    };
    chromium = {
      enable = true;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
        { id = "nngceckbapebfimnlniiiahkandclblb"; }
      ];
    };
    git = {
      enable = true;
      userName = "TimisRobert";
      userEmail = "roberttimis@gmail.com";
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
    };
    alacritty = {
      enable = true;
      settings = {
        import = [ ../../assets/kanagawa.yml ];
        window = { opacity = 0.95; };
        font = { size = 12.0; };
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
    rbw = {
      enable = true;
      settings = {
        email = "roberttimis@gmail.com";
        base_url = "https://vault.roberttimis.com";
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
          name = "forgit";
          src =
            pkgs.fishPlugins.forgit.src;
        }
      ];
      functions = {
        printscreen = "grim -g $(slurp -d) - | wl-copy -t image/png";
        screenshot = "grim -g $(slurp) $argv";
      };
    };
  };
}
