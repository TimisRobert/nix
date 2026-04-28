{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./claude
    ./dms.nix
  ];

  home = {
    homeDirectory = "/home/rob";
    username = "rob";
    stateVersion = "26.05";
    sessionVariables = {
      WLR_RENDERER = "vulkan";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      ELIXIR_ERL_OPTIONS = "-kernel shell_history enabled";
      TF_PLUGIN_CACHE_DIR = "$HOME/.terraform.d/plugin-cache";
      PROTON_PASS_LINUX_KEYRING = "dbus";
    };
    sessionPath = [
      "$HOME/.local/bin"
    ];
    packages = [
      # LSPs
      pkgs.buf
      pkgs.taplo
      pkgs.inotify-tools
      pkgs.ghostscript
      pkgs.helm-ls
      pkgs.dockerfile-language-server
      pkgs.shellcheck
      pkgs.pyright
      pkgs.ruff
      pkgs.terraform-ls
      # pkgs.nodePackages."@astrojs/language-server"
      pkgs.beamPackages.expert
      # pkgs.zls
      pkgs.yaml-language-server
      pkgs.tailwindcss-language-server
      pkgs.emmet-ls
      pkgs.eslint
      pkgs.typescript-language-server
      pkgs.prettier
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
      pkgs.gopls
      # Misc
      (pkgs.writers.writePython3Bin "unlock-keyring" {
          libraries = [pkgs.python3Packages.pygobject3];
          flakeIgnore = ["E501" "E402"];
        } ''
          import subprocess
          import sys
          from pathlib import Path

          import gi
          gi.require_version("Gio", "2.0")
          gi.require_version("GLib", "2.0")
          from gi.repository import Gio, GLib

          secret_file = Path.home() / ".local/share/keyring-secret.gpg"
          if not secret_file.exists():
              print(f"No encrypted keyring secret found at {secret_file}", file=sys.stderr)
              sys.exit(1)

          pw = subprocess.check_output(
              ["${pkgs.gnupg}/bin/gpg", "--quiet", "--yes", "--batch", "--decrypt", str(secret_file)]
          ).decode().strip()

          bus = Gio.bus_get_sync(Gio.BusType.SESSION)

          result = bus.call_sync(
              "org.freedesktop.secrets",
              "/org/freedesktop/secrets",
              "org.freedesktop.Secret.Service",
              "OpenSession",
              GLib.Variant("(sv)", ("plain", GLib.Variant("s", ""))),
              GLib.VariantType("(vo)"),
              Gio.DBusCallFlags.NONE,
              -1,
              None,
          )
          _, session_path = result.unpack()

          secret = (session_path, bytes(), pw.encode(), "text/plain")
          bus.call_sync(
              "org.freedesktop.secrets",
              "/org/freedesktop/secrets",
              "org.gnome.keyring.InternalUnsupportedGuiltRiddenInterface",
              "UnlockWithMasterPassword",
              GLib.Variant("(o(oayays))", ("/org/freedesktop/secrets/collection/login", secret)),
              None,
              Gio.DBusCallFlags.NONE,
              -1,
              None,
          )
        '')
      pkgs.bubblewrap
      pkgs.socat
      pkgs.mpc
      pkgs.xwayland-satellite
      pkgs.proton-vpn-cli
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
      pkgs.just
      pkgs.sox
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
                      plugin = "librnnoise_ladspa";
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
      nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nix/astronvim";
    };
    mimeApps.enable = true;
  };

  stylix.targets.neovim.enable = false;

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
    mpd = {
      enable = true;
      network.startWhenNeeded = true;
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"
        }
      '';
    };
    mpd-mpris.enable = true;
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
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "${config.home.homeDirectory}/projects/nix";
    };
    gpg = {
      enable = true;
      scdaemonSettings = {
        disable-ccid = true;
      };
    };
    taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior3;
    };
    btop.enable = true;
    k9s.enable = true;
    lsd.enable = true;
    bat.enable = true;
    jq.enable = true;
    lf.enable = true;
    zathura.enable = true;
    zoxide.enable = true;
    fzf.enable = true;
    fd.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
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
      sideloadInitLua = true;
      extraPackages = [
        pkgs.gcc
        pkgs.gnumake
      ];
    };
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      extensions = [
        "ghmbeldphafepmbegfdlkpapadhbakde" # proton pass
        "ddkjiahejlhfcafbddmgiahcphecmpfh"
      ];
      commandLineArgs = [
        "--enable-features=AcceleratedVideoEncoder"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
      ];
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
        git_branch.disabled = true;
        git_status.disabled = true;
        custom.jj = {
          when = "${pkgs.jj-starship}/bin/jj-starship detect";
          shell = ["${pkgs.jj-starship}/bin/jj-starship"];
          format = "\$output ";
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
      '';
    };
  };
}
