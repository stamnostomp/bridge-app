{
  description = "Bridge - Conflict Resolution App (Elm)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Development script that builds and serves the app
        dev = pkgs.writeScriptBin "dev" ''
          #!/usr/bin/env sh
          echo "Starting Bridge development server..."

          # Create public directory if it doesn't exist
          mkdir -p public

          # Build Elm app with debug mode
          echo "Building Elm app..."
          elm make src/Main.elm --output=public/main.js --debug

          # Start live server
          echo "Starting live server on http://localhost:8080"
          live-server public --port=8080 --entry-file=index.html --watch=src
        '';

        # Build script for production
        build = pkgs.writeScriptBin "build" ''
          #!/usr/bin/env sh
          echo "Building optimized Elm app..."
          mkdir -p public
          elm make src/Main.elm --output=public/main.js --optimize
          echo "Build complete! Files are in ./public/"
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Elm toolchain
            elmPackages.elm
            elmPackages.elm-format
            elmPackages.elm-test
            elmPackages.elm-review

            # Development server
            nodejs_20
            nodePackages.live-server

            # Development scripts
            dev
            build
          ];

          shellHook = ''
            echo "Bridge Development Environment"
            echo ""
            echo "Available commands:"
            echo "  dev              - Start development server with live reload"
            echo "  build            - Build optimized production app"
            echo "  elm-format       - Format Elm code"
            echo "  elm-test         - Run tests"
            echo "  elm-review       - Run code review"
            echo ""
            echo "Elm: $(elm --version)"
            echo "Node.js: $(node --version)"
          '';
        };

        # Production build
        packages.default = pkgs.stdenv.mkDerivation {
          name = "bridge-app";
          src = ./.;
          buildInputs = [ pkgs.elmPackages.elm ];
          buildPhase = ''
            elm make src/Main.elm --output=main.js --optimize
          '';
          installPhase = ''
            mkdir -p $out
            cp -r public/* $out/ 2>/dev/null || true
            cp main.js $out/
          '';
        };
      }
    );
}
