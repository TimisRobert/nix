{pkgs}:
pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ctx7";
  version = "0.3.2";

  src = pkgs.fetchFromGitHub {
    owner = "upstash";
    repo = "context7";
    rev = "ctx7@${finalAttrs.version}";
    hash = "sha256-H6QAgAoBBQ4ixEDxP7zFmMF4OlWSDn8i5sIuBVT0kj4=";
  };

  pnpmWorkspaces = ["ctx7"];

  pnpmDeps = pkgs.fetchPnpmDeps {
    inherit (finalAttrs) pname version src pnpmWorkspaces;
    pnpm = pkgs.pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-FzI5fGdX5r77vzr88UR+vvVITLOSP5x7NSi/cXB65Hs=";
  };

  nativeBuildInputs = [
    pkgs.nodejs
    pkgs.pnpmConfigHook
    pkgs.pnpm_10
    pkgs.makeBinaryWrapper
  ];

  buildPhase = ''
    runHook preBuild
    pnpm --filter ctx7 build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/ctx7}

    cp -r {packages,node_modules} $out/lib/ctx7/

    makeWrapper ${pkgs.lib.getExe pkgs.nodejs} $out/bin/ctx7 \
      --inherit-argv0 \
      --add-flags $out/lib/ctx7/packages/cli/dist/index.js

    runHook postInstall
  '';

  # Workspace self-reference symlink points back to source tree
  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "Context7 CLI - Query library documentation from the terminal";
    homepage = "https://context7.com";
    license = pkgs.lib.licenses.mit;
    mainProgram = "ctx7";
  };
})
