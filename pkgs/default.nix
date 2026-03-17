{ pkgs }:

{
  graypaper = pkgs.callPackage ./graypaper { };

  polkadot = pkgs.callPackage ./polkadot-sdk/polkadot.nix { };
  polkadot-runtime-benchmarks = pkgs.callPackage ./polkadot-sdk/polkadot.nix { features = [ "runtime-benchmarks" ]; };
  polkadot-omni-node = pkgs.callPackage ./polkadot-sdk/polkadot-omni-node.nix { };
  polkadot-omni-node-runtime-benchmarks = pkgs.callPackage ./polkadot-sdk/polkadot-omni-node.nix { features = [ "runtime-benchmarks" ]; };
  polkadot-parachain = pkgs.callPackage ./polkadot-sdk/polkadot-parachain.nix { };
  polkadot-parachain-runtime-benchmarks = pkgs.callPackage ./polkadot-sdk/polkadot-parachain.nix { features = [ "runtime-benchmarks" ]; };
  chain-spec-builder = pkgs.callPackage ./polkadot-sdk/chain-spec-builder.nix { };
  frame-omni-bencher = pkgs.callPackage ./polkadot-sdk/frame-omni-bencher.nix { };
  subkey = pkgs.callPackage ./polkadot-sdk/subkey.nix { };

  psvm = pkgs.callPackage ./psvm { };
  srtool-cli = pkgs.callPackage ./srtool-cli { };
  subalfred = pkgs.callPackage ./subalfred { };
  subrpc = pkgs.callPackage ./subrpc { };
  subwasm = pkgs.callPackage ./subwasm { };
  subxt-cli = pkgs.callPackage ./subxt-cli { };
  try-runtime-cli = pkgs.callPackage ./try-runtime-cli { };
  zepter = pkgs.callPackage ./zepter { };
  zombienet = pkgs.zombienet.default;
}
