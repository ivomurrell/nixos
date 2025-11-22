{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
        home-manager.follows = "";
      };
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tangled = {
      url = "git+https://tangled.org/tangled.org/core?ref=refs/tags/v1.11.0-alpha";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-compat.follows = "";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      nixvim,
      agenix,
      fenix,
      tangled,
      ...
    }:
    let
      system = "aarch64-linux";
    in
    {
      nixosConfigurations.cherry = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          {
            nixpkgs.overlays = [
              fenix.overlays.default
              (final: prev: {
                agenix = agenix.packages.${system}.default;
                jujutsu = nixpkgs-unstable.legacyPackages.${system}.jujutsu;
              })
            ];
          }

          ./configuration.nix

          nixvim.nixosModules.nixvim
          agenix.nixosModules.default
          tangled.nixosModules.knot
        ];
      };
    };
}
