module Components.Navbar exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



-- VIEW


view : Html msg
view =
    nav
        [ class "bg-white-80 bb b--light-gray pv3 ph4 flex justify-between items-center"
        , style "backdrop-filter" "blur(10px)"
        ]
        [ -- Logo/Brand
          div
            [ class "flex items-center" ]
            [ h1
                [ class "ma0 f3 fw3 dark-gray" ]
                [ text "Bridge" ]
            ]

        -- User indicator
        , div
            [ class "flex items-center" ]
            [ div
                [ class "w2 h2 br-100 ba b--gray bg-gray" ]
                []
            ]
        ]
