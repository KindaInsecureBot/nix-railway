{
  description = "Logos/LEZ development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        rustToolchain = pkgs.rust-bin.nightly.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
          targets = [ "wasm32-unknown-unknown" ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "logos-lez-dev";

          buildInputs = [
            # Rust
            rustToolchain

            # C/C++ build tools
            pkgs.cmake
            pkgs.ninja
            pkgs.pkg-config
            pkgs.gcc
            pkgs.llvmPackages.clang

            # Qt 6
            pkgs.qt6.qtbase
            pkgs.qt6.qtdeclarative
            pkgs.qt6.qtremoteobjects
            pkgs.qt6.wrapQtAppsHook

            # Crypto / networking
            pkgs.openssl
            pkgs.protobuf

            # Node.js tooling
            pkgs.nodejs_20
            pkgs.nodePackages.npm

            # Handy dev tools
            pkgs.git
            pkgs.jq
            pkgs.ripgrep
            pkgs.fd
          ];

          shellHook = ''
            echo "Logos/LEZ dev shell ready"
            echo "Rust: $(rustc --version)"
            echo "Node: $(node --version)"
            export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export OPENSSL_DIR="${pkgs.openssl.dev}"
            export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
          '';
        };
      });
}
