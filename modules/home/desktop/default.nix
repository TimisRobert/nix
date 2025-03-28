{pkgs, ...}: {
  imports = [../.];

  home = {
    persistence."/persist/home/rob" = {
      directories = [
        ".local/share/Steam"
      ];
    };
    packages = [
      pkgs.gamemode
    ];
  };
}
