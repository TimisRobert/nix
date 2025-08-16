{
  pkgs,
  config,
  ...
}: {
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = [pkgs.proton-ge-bin];
    };
    gamemode.enable = true;
  };

  boot.initrd.kernelModules = ["nvidia"];
  # boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];

  hardware = {
    keyboard.qmk.enable = true;
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      nvidiaSettings = true;
      powerManagement.enable = true;
      modesetting.enable = true;
    };
  };

  networking = {
    hostId = "d5a63149";
    hostName = "desktop";
  };

  services = {
    xserver.videoDrivers = ["nvidia"];
    # ollama = {
    #   enable = true;
    #   acceleration = "cuda";
    #   environmentVariables = {
    #     OLLAMA_FLASH_ATTENTION = "1";
    #     OLLAMA_CONTEXT_LENGTH = "128000";
    #     GGML_CUDA_ENABLE_UNIFIED_MEMORY = "1";
    #   };
    #   loadModels = [
    #     "hf.co/unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF:UD-Q3_K_XL"
    #     "hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:UD-Q3_K_XL"
    #     "hf.co/Qwen/Qwen3-Embedding-8B-GGUF:Q4_K_M"
    #     "hf.co/Qwen/Qwen3-Embedding-0.6B-GGUF:f16"
    #   ];
    # };
    litellm = {
      enable = true;
      port = 10000;
      environmentFile = config.age.secrets.litellm.path;
      settings = {
        general_settings = {
          master_key = "sk-1111";
        };
        litellm_settings = {
          # enable_preview_features = true;
          drop_params = true;
          cache = true;
          cache_params = {
            type = "local";
          };
        };
        model_list = [
          # {
          #   model_name = "local/qwen3-coder";
          #   litellm_params = {
          #     model = "ollama_chat/hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:UD-Q3_K_XL";
          #   };
          # }
          # {
          #   model_name = "local/qwen3-instruct";
          #   litellm_params = {
          #     model = "ollama_chat/hf.co/unsloth/Qwen3-30B-A3B-Instruct-2507-GGUF:UD-Q3_K_XL";
          #   };
          # }
          # {
          #   model_name = "local/qwen3-embedding";
          #   litellm_params = {
          #     model = "ollama/hf.co/Qwen/Qwen3-Embedding-8B-GGUF:Q4_K_M";
          #   };
          # }
          # {
          #   model_name = "local/qwen3-embedding-small";
          #   litellm_params = {
          #     model = "ollama/hf.co/Qwen/Qwen3-Embedding-0.6B-GGUF:f16";
          #   };
          # }
          {
            model_name = "novita/qwen/qwen3-coder-480b-a35b-instruct";
            litellm_params = {
              model = "novita/qwen/qwen3-coder-480b-a35b-instruct";
              api_key = "os.environ/NOVITA_API_KEY";
            };
          }
          {
            model_name = "novita/qwen/qwen3-30b-a3b-fp8";
            litellm_params = {
              model = "novita/qwen/qwen3-30b-a3b-fp8";
              api_key = "os.environ/NOVITA_API_KEY";
            };
          }
          {
            model_name = "novita/qwen/qwen3-235b-a22b-instruct-2507";
            litellm_params = {
              model = "novita/qwen/qwen3-235b-a22b-instruct-2507";
              api_key = "os.environ/NOVITA_API_KEY";
            };
          }
          {
            model_name = "novita/zai-org/glm-4.5";
            litellm_params = {
              model = "novita/zai-org/glm-4.5";
              api_key = "os.environ/NOVITA_API_KEY";
            };
          }
          {
            model_name = "zai/glm-4.5";
            litellm_params = {
              model = "openai/glm-4.5";
              api_base = "https://api.z.ai/api/paas/v4";
              api_key = "os.environ/ZAI_API_KEY";
            };
          }
          {
            model_name = "zai/glm-4.5-air";
            litellm_params = {
              model = "openai/glm-4.5-air";
              api_base = "https://api.z.ai/api/paas/v4";
              api_key = "os.environ/ZAI_API_KEY";
            };
          }
          {
            model_name = "zai/glm-4.5-flash";
            litellm_params = {
              model = "openai/glm-4.5-flash";
              api_base = "https://api.z.ai/api/paas/v4";
              api_key = "os.environ/ZAI_API_KEY";
            };
          }
          {
            model_name = "cerebras/qwen-3-coder-480b";
            litellm_params = {
              model = "cerebras/qwen-3-coder-480b";
              api_key = "os.environ/CEREBRAS_API_KEY";
            };
          }
          {
            model_name = "nebius/qwen/qwen2.5-vl-72b-instruct";
            litellm_params = {
              model = "nebius/Qwen/Qwen2.5-VL-72B-Instruct";
              api_key = "os.environ/NEBIUS_API_KEY";
            };
          }
          {
            model_name = "nebius/qwen/qwen3-embedding-8b";
            litellm_params = {
              model = "nebius/Qwen/Qwen3-Embedding-8B";
              api_key = "os.environ/NEBIUS_API_KEY";
            };
          }
        ];
      };
    };
    zrepl = {
      enable = true;
      settings = {
        jobs = [
          {
            name = "backuppool_sink";
            type = "sink";
            root_fs = "backuppool";
            recv = {
              placeholder = {
                encryption = "inherit";
              };
            };
            serve = {
              type = "local";
              listener_name = "backuppool_sink";
            };
          }
          {
            name = "push_to_drive";
            type = "push";
            send = {
              encrypted = false;
            };
            connect = {
              type = "local";
              listener_name = "backuppool_sink";
              client_identity = config.networking.hostName;
            };
            filesystems = {
              "zpool/projects" = true;
              "zpool/documents" = true;
            };
            replication = {
              protection = {
                initial = "guarantee_resumability";
                incremental = "guarantee_incremental";
              };
            };
            snapshotting = {
              type = "manual";
            };
            pruning = {
              keep_sender = [
                {
                  type = "regex";
                  regex = ".*";
                }
              ];
              keep_receiver = [
                {
                  type = "grid";
                  grid = "1x1h(keep=all) | 24x1h | 14x1d | 3x30d";
                  regex = "^zrepl_.*";
                }
              ];
            };
          }
          {
            name = "snapshot";
            type = "snap";
            filesystems = {
              "zpool/projects" = true;
              "zpool/documents" = true;
            };
            snapshotting = {
              type = "periodic";
              prefix = "zrepl_";
              interval = "10m";
              timestamp_format = "iso-8601";
            };
            pruning = {
              keep = [
                {
                  type = "grid";
                  grid = "1x1h(keep=all) | 24x1h | 14x1d | 3x30d";
                  regex = "^zrepl_.*";
                }
              ];
            };
          }
        ];
      };
    };
  };
}
