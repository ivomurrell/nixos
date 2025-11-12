let
  mbp14 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMvb1u92smPBaQDUbKuXWaPq4dFA9a1Ce3Oq8Xvyzuyb";
  users = [mbp14];
  hetzner = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMbG84dIDjSFMTLcQVQ8h86HzDhZm51Uz6jMrnzJgmUp root@cherry";
  systems = [hetzner];
in
{
  "apple-music-auth-key.age".publicKeys = users ++ systems;
  "myivo-dot-env.age".publicKeys = users ++ systems;
}
