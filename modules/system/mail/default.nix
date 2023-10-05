{ pkgs, config, inputs, modulesPath, lib, hostName, ... }: {
  imports = [
    "${modulesPath}/profiles/hardened.nix"
    inputs.agenix.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
    inputs.simple-nixos-mailserver.nixosModules.default
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
        directories = [ "/var/log" "/var/lib/acme" ];
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

  age = {
    identityPaths = [ "/nix/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      hetznerDns = {
        file = ../../../secrets/hetznerDns.age;
        owner = "acme";
        group = "acme";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = { email = "roberttimis@gmail.com"; };
    certs = {
      "mail.roberttimis.com" = {
        domain = "mail.roberttimis.com";
        dnsProvider = "hetzner";
        credentialsFile = config.age.secrets.hetznerDns.path;
      };
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.roberttimis.com";
    domains = [ "roberttimis.com" ];
    certificateScheme = "acme";
    localDnsResolver = false;
    loginAccounts = {
      "info@roberttimis.com" = {
        hashedPassword =
          "$2b$05$7U57IvrtjdhrbmSMC6wM0uzsEicuhGSSw2c4YcbnaHwWLQpoA9PVK";
      };
    };
  };

  programs.zsh.enable = true;

  services = {
    resolved.enable = true;
    openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-wan" = {
        matchConfig.Name = "enp1s0";
        networkConfig = { Address = [ "2a01:4f8:c012:7759::/64" ]; };
        routes = [{ routeConfig.Gateway = "fe80::1"; }];
        DHCP = "ipv4";
      };
    };
  };

  networking = {
    inherit hostName;
    useDHCP = false;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  zramSwap.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users = {
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
