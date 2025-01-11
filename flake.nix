{
  description = ''
    A collection of Nix packages related to the Polkadot ecosystem.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    foundry.url =
      "github:shazow/foundry.nix/monthly"; # Use monthly branch for permanent releases
    zombienet = {
      url = "github:paritytech/zombienet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      fenix,
      foundry,
      zombienet,
      ...
    }:
    let
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            fenix.overlays.default
            foundry.overlay
            zombienet.overlays.default
          ];
        };
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f system (mkPkgs system));
    in
    {
      checks = eachSystem (
        system: pkgs: {
          buildAll = pkgs.symlinkJoin {
            name = "build-all-packages";
            paths = builtins.attrValues self.packages.${system};
          };
        }
      );
      devShells = eachSystem (
        system: pkgs: {
          default = import ./shell.nix { inherit pkgs; };
        }
      );
      packages = eachSystem (system: pkgs: import ./pkgs { inherit pkgs; });
    }
    // {
      overlays = {
        default =
          final: prev:
          import ./overlay.nix final (
            prev.appendOverlays [
              fenix.overlays.default
              zombienet.overlays.default
            ]
          );
      };
    };
}
