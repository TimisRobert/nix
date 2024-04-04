{
  config,
  pkgs,
  ...
}: {
  env.MIX_HOME = "${config.env.DEVENV_STATE}/.mix";

  packages = [
    pkgs.lexical
    pkgs.elixir
  ];
}
