module Components.Tabs exposing (Tab(..), view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



-- TYPES


type Tab
    = Open
    | Resolved



-- VIEW


view : Tab -> (Tab -> msg) -> Int -> Int -> Html msg
view activeTab onTabClick openCount resolvedCount =
    div
        [ class "flex" ]
        [ -- Open tab
          button
            [ class (tabClasses activeTab Open)
            , onClick (onTabClick Open)
            ]
            [ text ("Open (" ++ String.fromInt openCount ++ ")") ]

        -- Resolved tab
        , button
            [ class (tabClasses activeTab Resolved)
            , onClick (onTabClick Resolved)
            ]
            [ text ("Resolved (" ++ String.fromInt resolvedCount ++ ")") ]
        ]



-- HELPERS


tabClasses : Tab -> Tab -> String
tabClasses activeTab thisTab =
    let
        baseClasses =
            "ph4 pv2 f6 bg-white ba bn br0 pointer"

        activeClasses =
            "fw5 dark-gray bb b--dark-gray"

        inactiveClasses =
            "fw4 gray bg-white-50 bb b--light-gray"
    in
    if activeTab == thisTab then
        baseClasses ++ " " ++ activeClasses

    else
        baseClasses ++ " " ++ inactiveClasses
