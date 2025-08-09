let
  rob = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvR28lwcOKIk7VRo/bXzxQGnA5evdsGcNZCy3BA6DDR rob@RobertTimis";
  users = [rob];
in {
  "litellm.age".publicKeys = users;
  "gitlab.age".publicKeys = users;
}
