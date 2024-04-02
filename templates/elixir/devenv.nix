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
  ];
}
