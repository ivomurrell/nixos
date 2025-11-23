{ ... }:

{
  imports = [
    ./services/myivo.nix
    ./services/anki.nix
    ./services/pds.nix
    ./services/tangled.nix
  ];

  services.caddy = {
    enable = true;
    globalConfig = ''
      email ivo@cherry.computer
    '';
  };
}
