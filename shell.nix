{
  pkgs ? import <nixpkgs> { },
  fenixPkgs,
  channel ? "stable",
}:

let
  channelPkgs = fenixPkgs.${channel};
  rust-toolchain = fenixPkgs.combine [
    (channelPkgs.withComponents [
      "cargo"
      "clippy"
      "llvm-tools"
      "rust-analyzer"
      "rust-src"
      "rustc"
    ])
    fenixPkgs.latest.rustfmt
    fenixPkgs.targets.wasm32-unknown-unknown.${channel}.rust-std
  ];
  cargoLinker =
    with pkgs;
    let
      mold = wrapBintoolsWith { bintools = pkgs.mold; };
      rustTarget = stdenv.hostPlatform.rust.cargoEnvVarTarget;
      rustflags =
        if stdenv.isDarwin then
          "-Clink-arg=-fuse-ld=${llvmPackages.lld}/bin/ld64.lld"
        else
          "-Clink-arg=-fuse-ld=${mold}/bin/ld.mold -Clink-arg=-Wl,--no-rosegment";
    in
    {
      "CARGO_TARGET_${rustTarget}_LINKER" = "clang";
      "CARGO_TARGET_${rustTarget}_RUSTFLAGS" = rustflags;
    };
in
with pkgs;
mkShell.override { stdenv = clangStdenv; } (
  {
    packages = [
      llvmPackages.lld
      openssl
      pkg-config
      rust-toolchain
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      rust-jemalloc-sys-unprefixed
    ];

    LIBCLANG_PATH = lib.makeLibraryPath [ llvmPackages.libclang ];
    RUST_SRC_PATH = "${rust-toolchain}/lib/rustlib/src/rust/library";

    OPENSSL_NO_VENDOR = 1;
    PROTOC = "${lib.makeBinPath [ protobuf ]}/protoc";
    ROCKSDB_LIB_DIR = lib.makeLibraryPath [ rocksdb ];
  }
  // cargoLinker
)
