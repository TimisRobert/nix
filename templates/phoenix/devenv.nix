{
  config,
  pkgs,
  ...
}: {
  env.MIX_HOME = "${config.env.DEVENV_STATE}/.mix";

  packages = [
    pkgs.lexical
    pkgs.elixir
    pkgs.inotify-tools
    pkgs.nodejs
    pkgs.nodePackages.pnpm
    pkgs.gnumake
    pkgs.gcc
    pkgs.buildah
  ];

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    initialDatabases = [{name = "";}];
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
