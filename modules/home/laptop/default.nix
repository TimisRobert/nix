{...}: {
  imports = [../.];

  wayland.windowManager.hyprland.settings = {
    bind = [
      " , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      " , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      " , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      " , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      " , XF86AudioPlay, exec, playerctl play-pause"
      " , XF86AudioPause, exec, playerctl play-pause"
      " , XF86AudioNext, exec, playerctl next"
      " , XF86AudioPrev, exec, playerctl previous"
      " , XF86MonBrightnessUp, exec, light -A 5"
      " , XF86MonBrightnessDown, exec, light -U 5"
    ];
    # gestures = {
    #   workspace_swipe = true;
    #   workspace_swipe_fingers = 3;
    # };
  };
}
