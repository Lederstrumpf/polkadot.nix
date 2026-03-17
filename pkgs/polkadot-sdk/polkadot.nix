{
  callPackage,
  lib,
  features ? [],
}:

(callPackage ./generic.nix {
  inherit features;
  pname = "polkadot";
  target = "polkadot";
  description = "Implementation of a https://polkadot.network node in Rust based on the Substrate framework";
  license = lib.licenses.gpl3Only;
}).overrideAttrs
  (_: {
    doCheck = false;
  })
