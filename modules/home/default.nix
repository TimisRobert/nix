{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

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
      XDG_CURRENT_DESKTOP = "sway";
      EDITOR = "nvim";
      ELIXIR_ERL_OPTIONS = "-kernel shell_history enabled";
    };
    persistence = {
      "/nix/persist/home/rob" = {
        directories = [
          "projects"
          "documents"
          ".cache/nix"
          ".config/qmk"
          ".mozilla"
          ".local/share/nvim"
          ".local/state/nvim"
          ".local/share/direnv"
          ".local/share/zoxide"
          ".local/share/fish"
          ".ssh"
          ".aws"
          ".mix"
        ];
        files = [];
        allowOther = true;
      };
    };
    packages = [
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
      workspace 1
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
      bars = [{command = "waybar";}];
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_options = "caps:ctrl_modifier";
          # xkb_variant = "colemak";
        };
      };
    };
  };

  services = {
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
      withNodeJs = true;
      withPython3 = true;
      extraPackages = [
        pkgs.gnumake
        pkgs.gcc
        # Astro
        pkgs.nodePackages."@astrojs/language-server"
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
        pkgs.elixir-ls
      ];
    };
    firefox = {
      enable = true;
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
  };
}
