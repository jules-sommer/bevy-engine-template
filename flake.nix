# in flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        
        nativeBuildInputs = with pkgs; [
          rustToolchain
          pkg-config
        ];
        
        buildInputs = with pkgs; [
          udev alsa-lib vulkan-loader
          xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr # To use the x11 feature
          openssl
          pkg-config
          openssl.dev
          clang
          cmake
          gcc
          wayland
          wayland.dev
          zlib
          glib
          libxkbcommon
          libxkbcommon.dev
        ];
      in
      with pkgs;
      {
        devShells.default = mkShell {
          inherit buildInputs nativeBuildInputs;
          LD_LIBRARY_PATH = lib.makeLibraryPath (
            [
              # add some stuffs here
            ]
            ++ buildInputs
            ++ nativeBuildInputs
          );
          RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
          OPENSSL_DIR = "${pkgs.openssl.out}";
          OPENSSL_LIB_DIR = lib.makeLibraryPath [ pkgs.openssl ];
        };
      }
    );
}

