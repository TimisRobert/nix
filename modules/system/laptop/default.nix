{...}: {
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  environment = {
    # persistence = {
    #   "/persist/laptop" = {directories = ["/var/cache/powertop"];};
    # };
  };

  programs.dank-material-shell.greeter.compositor.customConfig = ''
    hotkey-overlay {
      skip-at-startup
    }
    environment {
      DMS_RUN_GREETER "1"
    }
    gestures {
      hot-corners {
        off
      }
    }
    layout {
      background-color "#000000"
    }
    cursor {
      xcursor-theme "Simp1e-Adw-Dark"
      xcursor-size 16
    }
    output "eDP-1" {
      mode "1920x1200@60"
      scale 1
    }
  '';

  networking.hostName = "laptop";
}
