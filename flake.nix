{
  description = "Bridge - Conflict Resolution App (Elm + Supabase)";

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

        # Custom Elm packages and tools
        elmPackages = with pkgs.elmPackages; [
          elm
          elm-format
          elm-review
          elm-test
          elm-analyse
        ];

        # Development tools
        devTools = with pkgs; [
          # Core development
          nodejs_20
          nodePackages.npm
          nodePackages.live-server

          # Code quality
          nodePackages.prettier

          # HTTP testing (for Supabase API)
          curl
          jq
          httpie

          # Git and project management
          git
          gh

          # Optional: Database tools for local Supabase
          postgresql
          docker
          docker-compose
        ];

        # Development scripts
        scripts = pkgs.writeScriptBin "dev-server" ''
          #!/bin/bash
          echo "Starting Elm development server..."
          echo "Building Elm app..."
          elm make src/Main.elm --output=public/main.js --debug
          echo "Starting live server on http://localhost:8080"
          live-server public --port=8080 --entry-file=index.html
        '';

        buildScript = pkgs.writeScriptBin "build-app" ''
          #!/bin/bash
          echo "Building optimized Elm app..."
          elm make src/Main.elm --output=public/main.js --optimize
          echo "Build complete! Files are in ./public/"
        '';

        testScript = pkgs.writeScriptBin "test-app" ''
          #!/bin/bash
          echo "Running Elm tests..."
          elm-test
          echo "Running Elm review..."
          elm-review
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
            elmPackages
            ++ devTools
            ++ [
              scripts
              buildScript
              testScript
            ];

          shellHook = ''
                        echo "🌉 Welcome to Bridge Development Environment"
                        echo ""
                        echo "Available commands:"
                        echo "  elm reactor          - Start Elm reactor (localhost:8000)"
                        echo "  dev-server          - Start development server with live reload"
                        echo "  build-app           - Build optimized production app"
                        echo "  test-app            - Run tests and linting"
                        echo "  elm make src/Main.elm --output=public/main.js - Manual build"
                        echo ""
                        echo "Elm compiler: $(elm --version)"
                        echo "Node.js: $(node --version)"
                        echo ""
                        echo "Project structure:"
                        echo "  src/           - Elm source files"
                        echo "  public/        - Static assets and built files"
                        echo "  tests/         - Elm tests"
                        echo ""

                        # Create directories if they don't exist
                        mkdir -p src tests public

                        # Create basic index.html if it doesn't exist
                        if [ ! -f public/index.html ]; then
                          cat > public/index.html << 'EOF'
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Bridge - Conflict Resolution</title>
                <style>
                    body {
                        margin: 0;
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", sans-serif;
                    }
                </style>
            </head>
            <body>
                <div id="elm-app"></div>
                <script src="main.js"></script>
                <script>
                    var app = Elm.Main.init({
                        node: document.getElementById('elm-app')
                    });
                </script>
            </body>
            </html>
            EOF
                          echo "Created public/index.html"
                        fi

                        # Create basic Main.elm if it doesn't exist
                        if [ ! -f src/Main.elm ]; then
                          cat > src/Main.elm << 'EOF'
            module Main exposing (..)

            import Browser
            import Html exposing (Html, div, h1, text)
            import Html.Attributes exposing (style)


            -- MAIN

            main =
                Browser.sandbox { init = init, update = update, view = view }


            -- MODEL

            type alias Model =
                { message : String }


            init : Model
            init =
                { message = "Welcome to Bridge - Conflict Resolution App" }


            -- UPDATE

            type Msg
                = NoOp


            update : Msg -> Model -> Model
            update msg model =
                case msg of
                    NoOp ->
                        model


            -- VIEW

            view : Model -> Html Msg
            view model =
                div
                    [ style "display" "flex"
                    , style "justify-content" "center"
                    , style "align-items" "center"
                    , style "height" "100vh"
                    , style "background" "linear-gradient(135deg, #667eea 0%, #764ba2 100%)"
                    , style "color" "white"
                    , style "text-align" "center"
                    ]
                    [ div []
                        [ h1 [] [ text model.message ]
                        , div [] [ text "Ready to build something amazing!" ]
                        ]
                    ]
            EOF
                          echo "Created src/Main.elm"
                        fi
          '';

          # Environment variables
          SUPABASE_URL = ""; # Add your Supabase URL here
          SUPABASE_ANON_KEY = ""; # Add your Supabase anon key here
        };

        # Build packages
        packages.default = pkgs.stdenv.mkDerivation {
          name = "bridge-app";
          src = ./.;
          buildInputs = elmPackages;
          buildPhase = ''
            elm make src/Main.elm --output=main.js --optimize
          '';
          installPhase = ''
            mkdir -p $out
            cp -r public/* $out/
            cp main.js $out/
          '';
        };
      }
    );
}
