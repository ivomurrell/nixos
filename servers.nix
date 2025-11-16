{ ... }:

{
  imports = [
    ./services/myivo.nix
    ./services/pds.nix
  ];

  services.caddy.enable = true;
}
