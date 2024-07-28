{lib, ...}: {
  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    "XF86MonBrightnessDown" = "exec light -U 5";
    "XF86MonBrightnessUp" = "exec light -A 5";
    "XF86AudioRaiseVolume" = "exec pamixer -i 5";
    "XF86AudioLowerVolume" = "exec pamixer -d 5";
    "XF86AudioMicMute" = "exec pamixer --source 111 -t";
    "XF86AudioMute" = "exec pamixer -t";
  };
}
