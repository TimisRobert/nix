{pkgs, ...}: let
  whisperModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin";
    hash = "sha256-ZNGCtEC5jVIDxPm9VBVE2ExgUZbE97hF36EfsjWU0eI=";
  };
  whisper = pkgs.whisper-cpp-vulkan;
  dictate = pkgs.writeShellScriptBin "dictate" ''
    ${pkgs.libnotify}/bin/notify-send -t 1000 "Listening..."
    text=$(${pkgs.sox}/bin/sox -t pulseaudio -d -r 16000 -c 1 -t wav - silence 1 0 1% 1 2.0 1% 2>/dev/null \
      | ${whisper}/bin/whisper-cli -nt -np -m ${whisperModel} -otxt - 2>/dev/null)
    ${pkgs.wlrctl}/bin/wlrctl keyboard type "''${text# }"
  '';
in {
  home.packages = [dictate];
}
