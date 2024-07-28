{
  lib,
  beamPackages,
  fetchFromGitHub,
  elixir,
}:
beamPackages.mixRelease rec {
  pname = "lexical";
  version = "latest";

  src = fetchFromGitHub {
    owner = "lexical-lsp";
    repo = "lexical";
    rev = "2360c344820ecda0000de948c22bc6323a776e44";
    hash = "sha256-KS46meMq/WUHjOoN1KGXz1PMVxM+Sl8SwmnYjxjszo8=";
  };

  mixFodDeps = beamPackages.fetchMixDeps {
    inherit pname version src;

    hash = "sha256-pqghYSBeDHfeZclC7jQU0FbadioTZ6uT3+InEUSW3rY=";
  };

  installPhase = ''
    runHook preInstall

    mix do compile --no-deps-check, package --path "$out"

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace "$out/bin/start_lexical.sh" --replace 'elixir_command=' 'elixir_command="${elixir}/bin/"'
    mv "$out/bin" "$out/libexec"
    makeWrapper "$out/libexec/start_lexical.sh" "$out/bin/lexical" --set RELEASE_COOKIE lexical
  '';

  meta = {
    description = "Lexical is a next-generation elixir language server";
    homepage = "https://github.com/lexical-lsp/lexical";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [GaetanLepage];
    mainProgram = "lexical";
    platforms = beamPackages.erlang.meta.platforms;
  };
}
