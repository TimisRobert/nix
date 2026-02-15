{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    inputs.stylix.homeModules.stylix
    ./dictate.nix
  ];

  home = {
    homeDirectory = "/home/rob";
    username = "rob";
    stateVersion = "25.11";
    sessionVariables = {
      WLR_RENDERER = "vulkan";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      ELIXIR_ERL_OPTIONS = "-kernel shell_history enabled";
      ENABLE_LSP_TOOL = "1";
      TF_PLUGIN_CACHE_DIR = "$HOME/.terraform.d/plugin-cache";
    };
    sessionPath = [
      "$HOME/.local/bin"
    ];
    packages = [
      # LSPs
      pkgs.taplo
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
      # pkgs.zls
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
      pkgs.just-lsp
      # ---
      pkgs.xwayland-satellite
      pkgs.protonvpn-gui
      pkgs.proton-pass-cli
      pkgs.wl-clipboard
      pkgs.docker-compose
      pkgs.kubectl
      pkgs.awscli2
      pkgs.duckdb
      pkgs.gping
      pkgs.duf
      pkgs.xh
      pkgs.doggo
      pkgs.yq-go
      pkgs.xdg-utils
      pkgs.unzip
      pkgs.zip
      pkgs.ast-grep
    ];
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      videos = "${config.home.homeDirectory}/videos";
    };
    configFile = {
      "pipewire/pipewire.conf.d/99-rnnoise.conf" = {
        text = builtins.toJSON {
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
                      plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
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
      };
      nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nix/assets/astronvim";
    };
    mimeApps.enable = true;
  };

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
    cursor = {
      name = "Simp1e-Adw-Dark";
      package = pkgs.simp1e-cursors;
      size = 16;
    };
    fonts = {
      monospace = {
        name = "Mononoki Nerd Font Mono";
        package = pkgs.nerd-fonts.mononoki;
      };
      sizes = {
        terminal = 12;
        desktop = 12;
        popups = 10;
        applications = 11;
      };
    };
    opacity.terminal = 0.95;
    polarity = "dark";
    targets = {
      neovim.enable = false;
      waybar.addCss = false;
      firefox.profileNames = ["default"];
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtlSsh = 86400;
      defaultCacheTtl = 86400;
      maxCacheTtl = 86400;
      maxCacheTtlSsh = 86400;
      pinentry = {
        package = pkgs.pinentry-qt;
      };
    };
  };

  programs = {
    nushell = {
      enable = true;
      plugins = [
        pkgs.nushellPlugins.polars
        pkgs.nushellPlugins.formats
        pkgs.nushellPlugins.query
      ];
    };
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "${config.home.homeDirectory}/projects/nix";
    };
    gpg = {
      enable = true;
      scdaemonSettings = {
        disable-ccid = true;
      };
    };
    nix-index-database.comma.enable = true;
    k9s.enable = true;
    lsd.enable = true;
    bat.enable = true;
    jq.enable = true;
    lf.enable = true;
    zathura.enable = true;
    zoxide.enable = true;
    fzf.enable = true;
    fd.enable = true;
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
        remotes.origin.auto-track-bookmarks = "glob:*";
      };
    };
    jjui.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      extraPackages = [
        pkgs.gcc
        pkgs.gnumake
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
    lazygit = {
      enable = true;
      settings = {
        disableStartupPopups = true;
        git.overrideGpg = true;
        git.pagers = [
          {
            pager = "delta --dark --paging=never";
            colorArg = "always";
          }
        ];
      };
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        set -U fish_color_param ${config.lib.stylix.colors.base06}
      '';
    };
  };
}
