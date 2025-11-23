{ config, ... }:
let
  ankiPort = 45723;
in
{
  age.secrets.ankiPassword.file = ../secrets/anki.age;

  services.anki-sync-server = {
    enable = true;
    port = ankiPort;
    users = [
      {
        username = "ivo";
        passwordFile = config.age.secrets.ankiPassword.path;
      }
    ];
  };

  services.caddy.virtualHosts."anki.cherry.computer" = {
    extraConfig = ''
      reverse_proxy localhost:${toString ankiPort}
    '';
  };
}
