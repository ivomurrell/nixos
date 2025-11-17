{ ... }:

{
  imports = [
    ./services/myivo.nix
    ./services/pds.nix
    ./services/tangled.nix
  ];

  services.caddy.enable = true;
}
