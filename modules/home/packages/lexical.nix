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
    rev = "6572a6a04a083e4857efad3dadef46200a70f5db";
    hash = "sha256-/FAS9VPPMMW7pKoMlYj8YU3i43LX3utUM5xTgSt9lBM=";
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

  meta = with lib; {
    description = "Lexical is a next-generation elixir language server";
    homepage = "https://github.com/lexical-lsp/lexical";
    license = licenses.asl20;
    maintainers = with maintainers; [GaetanLepage];
    mainProgram = "lexical";
    platforms = beamPackages.erlang.meta.platforms;
  };
}
