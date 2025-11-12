{ ... }:

{
  imports = [
    ./services/myivo.nix
  ];

  services.caddy.enable = true;
}
