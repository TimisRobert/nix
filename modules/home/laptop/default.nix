{...}: {
  imports = [../.];

  wayland.windowManager.hyprland.settings = {
    bind = [
      " , XF86AudioRaiseVolume, exec, pamixer -i 5 "
      " , XF86AudioLowerVolume, exec, pamixer -d 5 "
      " , XF86AudioMicMute, exec, pamixer --default-source -t"
      " , XF86AudioMute, exec, pamixer -t"
      " , XF86AudioPlay, exec, playerctl play-pause"
      " , XF86AudioPause, exec, playerctl play-pause"
      " , XF86AudioNext, exec, playerctl next"
      " , XF86AudioPrev, exec, playerctl previous"
      " , XF86MonBrightnessUp, exec, light -A 5"
      " , XF86MonBrightnessDown, exec, light -U 5"
    ];
    gestures = {
      workspace_swipe = true;
      workspace_swipe_fingers = 3;
    };
  };
}
