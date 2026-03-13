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
            const magenta = "\x1b[35m";
            const blue = "\x1b[34m";
            const reset = "\x1b[0m";

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

              const pct = Math.floor(data.context_window?.used_percentage || 0);
              const dots = 10;
              const filled = Math.floor(pct * dots / 100);
              const bar = Array.from({ length: dots }, (_, i) => {
                const c = i < filled ? (i < 5 ? green : i < 8 ? "\x1b[33m" : "\x1b[31m") : "\x1b[2m";
                return c + "●" + reset;
              }).join("");

              process.stdout.write(green + dir + reset + jjInfo + " " + bar + " " + blue + pct + "%" + reset);
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
