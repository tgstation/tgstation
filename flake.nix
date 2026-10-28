{
  description = "tgstation BYOND development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    byond-sdk.url = "github:FeudeyTF/byond-sdk-flake";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      byond-sdk,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        python = pkgs.python312.withPackages (
          ps: with ps; [
            pip
            setuptools
            wheel
            virtualenv

            # tools/requirements.txt
            pygit2
            bidict
            pillow
            pyyaml
            beautifulsoup4
            mysql-connector
            numpy
          ]
        );
      in
      {
        devShells.default = pkgs.mkShell {
          name = "byond";

          packages = with pkgs; [
            bash
            coreutils
            curl
            findutils
            git
            gawk
            gnugrep
            gzip
            jq
            openssl
            pkg-config
            unzip

            bun
            biome
            nodejs

            python

            byond-sdk.packages.${system}.DreamDaemon
            byond-sdk.packages.${system}.DreamMaker

            (writeShellScriptBin "run_server" ''
              exec ./tools/build/build.sh --wait-on-error server "$@"
            '')

            (writeShellScriptBin "build" ''
              exec ./tools/build/build.sh --wait-on-error build "$@"
            '')

            (writeShellScriptBin "tgui_dev" ''
              exec ./tools/build/build.sh --wait-on-error tgui-dev "$@"
            '')
          ];

          shellHook = ''
            set -e

            . ./dependencies.sh

            export PYTHONNOUSERSITE=1
            export PYTHONDONTWRITEBYTECODE=1


            DREAMLUAU_URL="https://github.com/$DREAMLUAU_REPO/releases/download/$DREAMLUAU_VERSION/libdreamluau.so"
            if [ ! -f ./libdreamluau.so ]; then
              echo "libdreamluau.so not found; downloading..."
              curl --fail --location --show-error --silent \
                "$DREAMLUAU_URL" \
                --output ./libdreamluau.so
            fi

            RUST_G_URL="https://github.com/tgstation/rust-g/releases/download/$RUST_G_VERSION/librust_g.so"
            if [ ! -f ./librust_g.so ]; then
              echo "librust_g.so not found; downloading..."
              curl --fail --location --show-error --silent \
                "$RUST_G_URL" \
                --output ./librust_g.so
            fi

          '';
        };
      }
    );
}
