module Components.Navbar exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



-- VIEW


view : Html msg
view =
    nav
        [ class "bg-white-80 bb b--light-gray flex justify-between items-center"
        , style "height" "80px"
        , style "padding-left" "60px"
        , style "padding-right" "60px"
        , style "border-bottom" "1px solid rgba(0,0,0,0.05)"
        , style "backdrop-filter" "blur(10px)"
        ]
        [ -- Logo/Brand
          div
            [ class "flex items-center" ]
            [ h1
                [ class "ma0 brand-text" ]
                [ text "Bridge" ]
            ]

        -- User indicator
        , div
            [ class "flex items-center" ]
            [ div
                [ class "relative" ]
                [ div
                    [ class "br-100 ba b--gray"
                    , style "width" "32px"
                    , style "height" "32px"
                    ]
                    []
                , div
                    [ class "absolute br-100 bg-gray"
                    , style "width" "16px"
                    , style "height" "16px"
                    , style "top" "8px"
                    , style "left" "8px"
                    ]
                    []
                ]
            ]
        ]
