let
  laptop =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvR28lwcOKIk7VRo/bXzxQGnA5evdsGcNZCy3BA6DDR rob@RobertTimis";
  desktop =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvR28lwcOKIk7VRo/bXzxQGnA5evdsGcNZCy3BA6DDR rob@RobertTimis";
  charon =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/Uq1z6b6ITxQv6YhjTV6kNoOiQWAqDiJivnPPByM4q root@nixos";
  mail =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG8C7G5H41FyNXIEIwTWkwez/E9AQsI3esQz3cxJ9y0l root@mail";
  site =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfhp9bKaG+uebgNQQgDWsaALneiLASDU5eVSBqHHKnK root@site";

  keys = [ laptop desktop charon mail site ];
in
{
  "wireguard/charon.age".publicKeys = keys;
  "wireguard/laptop.age".publicKeys = keys;
  "wireguard/desktop.age".publicKeys = keys;
  "vaultwarden.age".publicKeys = keys;
  "hetznerDns.age".publicKeys = keys;
  "pgadmin.age".publicKeys = keys;
  "forgejo.age".publicKeys = keys;
  "forgejoRunner.age".publicKeys = keys;
  "personal_site.age".publicKeys = keys;
  "infoPassword.age".publicKeys = keys;
  "borg/id_ed25519.age".publicKeys = keys;
  "borg/passphrase.age".publicKeys = keys;
}
