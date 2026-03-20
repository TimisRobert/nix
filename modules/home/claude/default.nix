{pkgs, ...}: let
  srt = pkgs.sandbox-runtime;
  srtLib = "${srt}/lib/node_modules/@anthropic-ai/sandbox-runtime";
in {
  programs.claude-code = {
    enable = true;
    package = null;
    skillsDir = ./skills;
    memory.source = ./CLAUDE.md;
    settings = {
      includeCoAuthoredBy = false;
      voiceEnabled = true;
      effort = "auto";
      permissions = {
        allow = [
          "Bash(ctx7 *)"
        ];
        deny = [];
        ask = [];
        defaultMode = "default";
      };
      statusLine = {
        type = "command";
        command = toString (pkgs.writers.writeJS "claude-status" {
            libraries = [];
          } ''
            const { execSync } = require("child_process");
            const path = require("path");

            const green = "\x1b[32m";
            const yellow = "\x1b[33m";
            const red = "\x1b[31m";
            const magenta = "\x1b[35m";
            const blue = "\x1b[34m";
            const dim = "\x1b[2m";
            const reset = "\x1b[0m";

            const miniBar = (pct, len) => {
              const filled = Math.floor(pct * len / 100);
              return Array.from({ length: len }, (_, i) => {
                const c = i < filled ? (pct < 50 ? green : pct < 80 ? yellow : red) : dim;
                return c + "▮" + reset;
              }).join("");
            };

            let input = "";
            process.stdin.on("data", (c) => (input += c));
            process.stdin.on("end", () => {
              const data = JSON.parse(input);
              const cwd = data.workspace?.current_dir || data.cwd || "";
              const dir = path.basename(cwd);

              let jjInfo = "";
              const jj = (tpl, rev) => execSync(
                "${pkgs.jujutsu}/bin/jj log --ignore-working-copy -r '" + rev + "' --no-graph -T '" + tpl + "'",
                { cwd, encoding: "utf8", stdio: ["pipe", "pipe", "ignore"] }
              ).trim();
              try {
                const bookmark = jj("bookmarks", "@").split(/\r?\n/)[0]?.trim();
                const changeId = jj("change_id.shortest()", "@");
                const baseBookmark = !bookmark ? jj("bookmarks", "heads(::@- & bookmarks())").split(/\r?\n/)[0]?.trim() : "";
                const label = bookmark || (baseBookmark ? baseBookmark + magenta + "@" : "") + magenta + changeId;
                if (label) jjInfo = " (" + magenta + label + reset + ")";
              } catch {}

              const ctxPct = Math.floor(data.context_window?.used_percentage || 0);
              const ctxBar = miniBar(ctxPct, 10);

              const rl = data.rate_limits;
              let rateInfo = "";
              if (rl) {
                const h5 = Math.round(rl.five_hour?.used_percentage ?? 0);
                const d7 = Math.round(rl.seven_day?.used_percentage ?? 0);
                const col = (p) => p < 50 ? green : p < 80 ? yellow : red;
                rateInfo = dim + " │ " + reset
                  + dim + "5h " + reset + miniBar(h5, 5) + " " + col(h5) + h5 + "%" + reset
                  + dim + " 7d " + reset + miniBar(d7, 5) + " " + col(d7) + d7 + "%" + reset;
              }

              process.stdout.write(green + dir + reset + jjInfo + dim + " │ " + reset + ctxBar + " " + blue + ctxPct + "%" + reset + rateInfo);
            });
          '');
      };
      enabledPlugins = {
        "pyright-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
      };
      spinnerTipsEnabled = true;
      autoUpdatesChannel = "latest";
      sandbox = {
        enabled = true;
        filesystem = {
          allowWrite = [
            "~/.local/share/task"
          ];
        };
        seccomp = {
          bpfPath = "${srtLib}/vendor/seccomp/x64/unix-block.bpf";
          applyPath = "${srtLib}/vendor/seccomp/x64/apply-seccomp";
        };
        network = {
          allowedDomains = [
            "*.context7.com"
            "context7.com"
          ];
        };
      };
    };
  };
}
