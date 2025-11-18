{ config, ... }:
let
  pdsHostname = "pds.cherry.computer";
  pdsPort = 31437;
in
{
  age.secrets.pdsEnvironment = {
    file = ../secrets/pds-dot-env.age;
    owner = "pds";
    group = "pds";
  };

  services.pds = {
    enable = true;
    settings = {
      PDS_PORT = pdsPort;
      PDS_HOSTNAME = pdsHostname;
    };
    environmentFiles = [ config.age.secrets.pdsEnvironment.path ];
  };

  services.caddy.virtualHosts.${pdsHostname} = {
    extraConfig = ''
      reverse_proxy localhost:${toString pdsPort}

      reverse_proxy /xrpc/app.bsky.unspecced.getAgeAssuranceState localhost:${toString pdsPort} {
        handle_response {
          copy_response_headers {
            exclude Content-Length
          }
          respond `{"lastInitiatedAt":"2025-07-25T07:38:28.157Z","status":"assured"}`
        }
      }
    '';
  };
}
