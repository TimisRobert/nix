{ pkgs, config, inputs, modulesPath, lib, hostName, ... }: {
  imports = [
    "${modulesPath}/profiles/hardened.nix"
    inputs.agenix.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "00:00";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;
  security.lockKernelModules = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams =
    lib.mkForce [ "page_alloc.shuffle=1" "init_on_alloc=1" "init_on_free=1" ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  environment = {
    systemPackages = [ pkgs.neovim ];
    persistence = {
      "/nix/persist" = {
        directories = [
          "/var/log"
          "/var/lib/acme"
          "/var/lib/containers"
          "/var/lib/forgejo"
          # "/var/lib/gitea-runner/runner"
          "/var/lib/bitwarden_rs"
          "/var/lib/postgresql"
        ];
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ];
      };
    };
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerSocket.enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
      defaultNetwork.settings = { dns_enabled = true; };
    };
  };

  age = {
    identityPaths = [ "/nix/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      hetznerDns = {
        file = ../../../secrets/hetznerDns.age;
        owner = "acme";
        group = "acme";
      };
      wireguard = {
        file = ../../../secrets/wireguard/${hostName}.age;
        owner = "systemd-network";
        group = "systemd-network";
      };
      vaultwarden = {
        file = ../../../secrets/vaultwarden.age;
        owner = "vaultwarden";
        group = "vaultwarden";
      };
      borgSsh = { file = ../../../secrets/borg/id_ed25519.age; };
      borgPassphrase = { file = ../../../secrets/borg/passphrase.age; };
      infoPassword = {
        file = ../../../secrets/infoPassword.age;
        owner = "forgejo";
        group = "forgejo";
      };
      forgejoRunner = {
        file = ../../../secrets/forgejoRunner.age;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = { email = "roberttimis@gmail.com"; };
    certs = {
      "wildcard.roberttimis.com" = {
        domain = "*.roberttimis.com";
        dnsProvider = "hetzner";
        credentialsFile = config.age.secrets.hetznerDns.path;
      };
      "roberttimis.com" = {
        domain = "roberttimis.com";
        dnsProvider = "hetzner";
        credentialsFile = config.age.secrets.hetznerDns.path;
      };
    };
  };

  programs.zsh.enable = true;

  services = {
    resolved.enable = true;
    borgbackup.jobs."charon" = {
      paths =
        [ "/var/lib/forgejo" "/var/lib/bitwarden_rs" "/var/backup/postgresql" ];
      exclude = [ ];
      repo = "u354949@u354949.your-storagebox.de:/home/charon";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.age.secrets.borgPassphrase.path}";
      };
      environment.BORG_RSH = "ssh -p 23 -i ${config.age.secrets.borgSsh.path}";
      compression = "auto,lzma";
      startAt = "*-*-* 00:00:00";
    };
    postgresql = {
      enable = true;
      ensureUsers = [{ name = "vaultwarden"; } { name = "forgejo"; }];
      ensureDatabases = [ "vaultwarden" "forgejo" ];
      authentication = ''
        local all postgres peer map=root
      '';
      identMap = ''
        root root postgres
        root postgres postgres
      '';
    };
    postgresqlBackup = {
      enable = true;
      startAt = "*-*-* 23:00:00";
    };
    vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://vault.roberttimis.com";
        ROCKET_PORT = "8000";
        ROCKET_ADDRESS = "127.0.0.1";
        DATABASE_URL = "postgresql://vaultwarden@/vaultwarden";
        DATABASE_MAX_CONNS = 1;
      };
      dbBackend = "postgresql";
      environmentFile = config.age.secrets.vaultwarden.path;
    };
    forgejo = {
      enable = true;
      database = { type = "postgres"; };
      mailerPasswordFile = config.age.secrets.infoPassword.path;
      settings = {
        actions = {
          ENABLED = true;
        };
        repository = {
          DEFAULT_BRANCH = "main";
        };
        ui = {
          DEFAULT_THEME = "forgejo-dark";
        };
        mailer = {
          ENABLED = true;
          PROTOCOL = "smtps";
          SMTP_ADDR = "mail.roberttimis.com";
          USER = "info@roberttimis.com";
          FROM = "Forgejo <info@roberttimis.com>";
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        server = {
          LANDING_PAGE = "explore";
          PROTOCOL = "http+unix";
          ROOT_URL = "https://git.roberttimis.com";
        };
      };
    };
    gitea-actions-runner = {
      package = pkgs.forgejo-actions-runner;
      instances.runner = {
        enable = false;
        name = "runner";
        url = config.services.forgejo.settings.server.ROOT_URL;
        tokenFile = config.age.secrets.forgejoRunner.path;
        labels = [
          "self-hosted:host"
          "ubuntu-latest:docker://catthehacker/ubuntu:act-latest"
        ];
      };

    };
    openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };
    nginx = {
      enable = true;
      clientMaxBodySize = "0";
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts = {
        "git.roberttimis.com" = {
          forceSSL = true;
          useACMEHost = "wildcard.roberttimis.com";
          locations."/".proxyPass = "http://unix:/run/forgejo/forgejo.sock";
        };
        "vault.roberttimis.com" = {
          forceSSL = true;
          useACMEHost = "wildcard.roberttimis.com";
          listenAddresses = [ "10.0.0.1" ];
          locations."/".proxyPass = "http://127.0.0.1:8000";
        };
      };
    };
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "wg0" = {
        netdevConfig = {
          Name = "wg0";
          Kind = "wireguard";
        };
        wireguardConfig = {
          ListenPort = 51820;
          PrivateKeyFile = config.age.secrets.wireguard.path;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "A79AHNRfis7Sm1fCdY9mCai4PRv5bojzeyPg4SnB8UU=";
              AllowedIPs = [ "10.0.0.2/32" ];
            };
          }
          {
            wireguardPeerConfig = {
              PublicKey = "7gEC/pXP4+67QrID9rLaPuwzUpz28KPS4H6nZ/VALVE=";
              AllowedIPs = [ "10.0.0.3/32" ];
            };
          }
        ];
      };
    };
    networks = {
      "10-wan" = {
        matchConfig.Name = "enp1s0";
        networkConfig = { Address = [ "2a01:4f8:c17:770b::/64" ]; };
        routes = [{ routeConfig.Gateway = "fe80::1"; }];
        DHCP = "ipv4";
      };
      "20-wg" = {
        matchConfig.Name = "wg0";
        networkConfig = { Address = [ "10.0.0.1/32" ]; };
        routes = [{
          routeConfig.Gateway = "10.0.0.1";
          routeConfig.Destination = "10.0.0.0/24";
        }];
        DHCP = "no";
      };
    };
  };

  networking = {
    inherit hostName;
    useDHCP = false;
    nftables.enable = true;
    nat = {
      enable = true;
      externalInterface = "enp41s0";
      internalInterfaces = [ "wg0" ];
    };
    firewall = {
      enable = true;
      allowedUDPPorts = [ 53 51820 ];
      allowedTCPPorts = [ 22 53 80 443 ];
    };
  };

  zramSwap.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users = {
      nginx = { extraGroups = [ "acme" ]; };
      root = {
        initialHashedPassword =
          "$6$8vuSs91NJ39SZy.b$b2ujBj2.iq9pPpZD0XL4yS7oJ0ODG2eGfGf7YVLt5OLkthe1tgKyEYPzRDTNO9J0Om1mVPIdpCWE7MIwKspDa/";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvR28lwcOKIk7VRo/bXzxQGnA5evdsGcNZCy3BA6DDR rob@RobertTimis"
        ];
      };
    };
  };

  system.stateVersion = "23.05";
}
