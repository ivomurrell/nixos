{
  pkgs,
  lib,
  config,
  ...
}:

let
  monorepo = pkgs.fetchgit {
    url = "https://tangled.org/cherry.computer/website";
    rev = "refs/heads/main";
    hash = "sha256-kXjHwS3dLW4Wv86qojEDUaVVdfXtddy/nAkWJVCx3ME=";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };
  monorepoSha = lib.trim (builtins.readFile "${monorepo}/COMMIT");

  rustToolchain = pkgs.fenix.stable.defaultToolchain;
  rustPlatform = pkgs.makeRustPlatform {
    rustc = rustToolchain;
    cargo = rustToolchain;
  };
  server = rustPlatform.buildRustPackage (finalAttrs: {
    pname = "myivo-server";
    version = "0.1.0";

    src = monorepo;
    sourceRoot = "${finalAttrs.src.name}/server";

    cargoHash = "sha256-9rSju9gaUdimGIGeVZmVrvaKRvXR8g+1NitjQG/f4iQ=";

    nativeBuildInputs = with pkgs; [
      pkg-config
    ];
    buildInputs = with pkgs; [
      openssl
    ];
  });

  frontend = pkgs.buildNpmPackage (finalAttrs: {
    pname = "autobivo";
    version = "1.0.0";

    src = monorepo;
    npmWorkspace = "frontend";

    npmDepsHash = "sha256-EVCm6kfLneG3EllgZmRMu0rHg9wnUQG5oq60qg9hBIY=";

    npmBuildScript = "build:production";

    installPhase = ''
      mkdir -p $out/build
      cp frontend/build/app.min.js $out/build/app.js
      cp frontend/build/app.min.css $out/build/app.css
    '';
  });
in
{
  age.secrets.myivoEnvironment.file = ../secrets/myivo-dot-env.age;
  age.secrets.myivoAppleMusicKey.file = ../secrets/apple-music-auth-key.age;

  systemd.services.myivo = {
    description = "personal website server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      APPLE_DEVELOPER_AUTH_KEY_PATH = "%d/apple-music-auth-key";
      MYIVO_GIT_SHA = monorepoSha;
    };

    serviceConfig = {
      Restart = "on-failure";
      ExecStart = "${server}/bin/myivo-server";

      EnvironmentFile = config.age.secrets.myivoEnvironment.path;
      LoadCredential = "apple-music-auth-key:${config.age.secrets.myivoAppleMusicKey.path}";

      DynamicUser = true;
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      RestrictRealtime = true;
    };
  };

  services.caddy.virtualHosts."cherry.computer" = {
    extraConfig = ''
      @backend path / /media/*

      root ${frontend}
      encode

      reverse_proxy @backend localhost:53465
      file_server
    '';
  };
}
