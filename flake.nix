{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tangled.url = "git+https://tangled.org/tangled.org/core?ref=refs/tags/v1.10.0-alpha";
  };

  outputs =
    {
      nixpkgs,
      nixvim,
      agenix,
      fenix,
      tangled,
      ...
    }@inputs:
    let
      system = "aarch64-linux";
    in
    {
      nixpkgs.overlays = [
        fenix.overlays.default
      ];

      nixosConfigurations.cherry = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs system; };
        modules = [
          {
            nixpkgs.overlays = [
              fenix.overlays.default
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
