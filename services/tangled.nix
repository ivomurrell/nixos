{ ... }:
let
  knotHostname = "knot.cherry.computer";
  knotPort = "8890";
in
{
  services.tangled.knot = {
    enable = true;
    server = {
      listenAddr = "0.0.0.0:${knotPort}";
      owner = "did:plc:oou2l7gjxuyg4cl7nzmirsdb";
      hostname = knotHostname;
    };
  };

  services.caddy.virtualHosts.${knotHostname} = {
    extraConfig = ''
      reverse_proxy localhost:${knotPort}
    '';
  };
}
