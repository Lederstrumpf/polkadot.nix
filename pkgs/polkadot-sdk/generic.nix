{
  pname,
  target,
  description,
  license,

  cacert,
  fetchFromGitHub,
  lib,
  openssl,
  pkg-config,
  protobuf,
  rocksdb_8_3,
  rust-jemalloc-sys-unprefixed,
  rustPlatform,
  rustc,
  stdenv,
}:

let
  rocksdb = rocksdb_8_3;
in
rustPlatform.buildRustPackage rec {
  inherit pname;

  version = "2506-2";

  src = fetchFromGitHub {
    owner = "Lederstrumpf";
    repo = "polkadot-sdk";
    rev = "force-portable-blake2_simd-${version}";
    hash = "sha256-Yvx0TxQjF3nd2ibbM3OsrSo0oPa3MSfvPAGjksRQfK4=";

    # the build process of polkadot requires a .git folder in order to determine
    # the git commit hash that is being built and add it to the version string.
    # since having a .git folder introduces reproducibility issues to the nix
    # build, we check the git commit hash after fetching the source and save it
    # into a .git_commit file, and then delete the .git folder. we can then use
    # this file to populate an environment variable with the commit hash, which
    # is picked up by polkadot's build process.
    leaveDotGit = true;
    postFetch = ''
      ( cd $out; git rev-parse --short HEAD > .git_commit )
      rm -rf $out/.git
    '';
  };

  preBuild = ''
    export SUBSTRATE_CLI_GIT_COMMIT_HASH=$(< .git_commit)
    rm .git_commit
  '';

  cargoHash = "sha256-tiyGmqI4L/GhMLwV+sGYXLWLJff8fhodXd2qh7zu2cw=";

  buildType = "production";
  buildAndTestSubdir = target;

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    rustc
    rustc.llvmPackages.lld
  ];

  # NOTE: jemalloc is used by default on Linux with unprefixed enabled
  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ rust-jemalloc-sys-unprefixed ];

  checkInputs = [
    cacert
  ];

  OPENSSL_NO_VENDOR = 1;
  PROTOC = "${protobuf}/bin/protoc";
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";

  meta = with lib; {
    inherit description license;

    homepage = "https://github.com/paritytech/polkadot-sdk";
    maintainers = with maintainers; [ andresilva ];
    # See Iso::from_arch in src/isa/mod.rs in cranelift-codegen-meta.
    platforms = intersectLists platforms.unix (
      platforms.aarch64 ++ platforms.s390x ++ platforms.riscv64 ++ platforms.x86
    );
  };
}
