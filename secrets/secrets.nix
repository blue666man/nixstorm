let
  age = "age1sz9xddpnn9lg975lmsvt95dqfxd26qm6ymrsj0zhym23x04vmv0qmkyqmu";
  xiphias = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKWC4BmRXXsSUkMPbe+hAlvg5H8+E6YnAQNrAL00E62 xiphias@encephalon";
  users = [xiphias];

  router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoWSC55Q+bK3a1cSVL5AvJ0bwZBdtS5WNjNn5v4OIZ2 root@router";
  systems = [router];
in {
  "proton-wg.age".publicKeys = [age router xiphias];
}
