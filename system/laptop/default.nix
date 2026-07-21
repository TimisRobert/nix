{...}: {
  boot.kernelParams = ["systemd.machine_id=2f06f12a09c142fca4fa0bc2c7bec40e"];
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  programs.noctalia-greeter.settings.output = {
    name = "eDP-1";
    width = 1920;
    height = 1200;
    scale = 1.0;
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  networking.hostName = "laptop";
}
