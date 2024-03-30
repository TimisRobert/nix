{
  config,
  inputs,
  pkgs,
  ...
}: let
  lexical = inputs.lexical.packages.${pkgs.system}.default;
in {
  env.MIX_HOME = "${config.env.DEVENV_STATE}/.mix";

  packages = [
    lexical
    pkgs.beam.packages.erlangR26.elixir_1_16
    pkgs.inotify-tools
    pkgs.awscli2
    pkgs.nodejs
    pkgs.nodePackages.pnpm
    pkgs.gnumake
    pkgs.gcc
    pkgs.buildah
  ];

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    initialDatabases = [{name = "sardgo";}];
    initialScript = ''
      create user postgres superuser;
    '';
    extensions = extensions: [
      extensions.postgis
    ];
  };

  processes = {
    phoenix = {
      exec = "mix setup && mix phx.server";
      process-compose = {
        depends_on.postgres.condition = "process_healthy";
      };
    };
  };
}
