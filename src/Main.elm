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
