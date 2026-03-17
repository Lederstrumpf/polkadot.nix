{
  callPackage,
  lib,
  features ? [],
}:

callPackage ./generic.nix {
  inherit features;
  pname = "polkadot-parachain";
  target = "cumulus/polkadot-parachain";
  description = "Polkadot omni node for system parachains";
  license = lib.licenses.gpl3Only;
}
