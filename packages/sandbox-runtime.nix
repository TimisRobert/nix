{pkgs}:
pkgs.buildNpmPackage rec {
  pname = "sandbox-runtime";
  version = "0.0.39";

  src = pkgs.fetchFromGitHub {
    owner = "anthropic-experimental";
    repo = "sandbox-runtime";
    tag = "v${version}";
    hash = "sha256-lR85GbpFEmxiCAQFrwSn+X2CMyp5dsaRcY+TnQ5U6eU=";
  };

  npmDepsHash = "sha256-ScM6bkh+Elfe9jd/lc5WzTkcF6ScfG7BqpUKfq0nNSg=";

  meta = {
    description = "Anthropic Sandbox Runtime - security boundaries for arbitrary processes";
    homepage = "https://github.com/anthropic-experimental/sandbox-runtime";
    license = pkgs.lib.licenses.asl20;
    mainProgram = "srt";
  };
}
