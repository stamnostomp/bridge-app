module Components.SessionCard exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time
import Types.Session exposing (Session, SessionStatus(..), sessionStatusColor, sessionStatusToString)



-- VIEW


view : Session -> Html msg
view session =
    div
        [ class "bg-white br2 shadow-2 pa0 ma2 w5 h5 flex flex-column"
        , style "min-height" "160px"
        , style "cursor" "pointer"
        ]
        [ -- Header with participant name and status indicator
          div
            [ class "bg-near-white br2 br--top pa2 flex justify-between items-center bb b--light-gray" ]
            [ h4
                [ class "ma0 f6 fw5 dark-gray truncate" ]
                [ text ("with " ++ session.participantName) ]
            , div
                [ class ("w3 h3 br-100 " ++ statusBgColor session.status) ]
                []
            ]

        -- Content area
        , div
            [ class "pa2 flex-auto flex flex-column justify-between" ]
            [ div []
                [ p
                    [ class "ma0 mb2 f7 gray" ]
                    [ text ("Round " ++ String.fromInt session.currentRound ++ " of " ++ String.fromInt session.totalRounds) ]
                , p
                    [ class "ma0 mb1 f7 light-silver" ]
                    [ text ("Started: " ++ formatTimeAgo session.startedAt) ]
                , p
                    [ class "ma0 mb2 f7 light-silver" ]
                    [ text ("Last activity: " ++ formatTimeAgo session.lastActivity) ]
                , p
                    [ class "ma0 mb2 f8 silver lh-copy" ]
                    [ text session.description ]
                ]

            -- Status badge
            , div
                [ class "flex justify-start" ]
                [ span
                    [ class ("f8 ph2 pv1 br3 " ++ statusTextColor session.status ++ " " ++ statusBorderColor session.status)
                    , style "border" "1px solid"
                    ]
                    [ text (sessionStatusToString session.status) ]
                ]
            ]
        ]



-- HELPERS


statusBgColor : SessionStatus -> String
statusBgColor status =
    case status of
        Waiting ->
            "bg-orange"

        Ready ->
            "bg-blue"

        Overdue ->
            "bg-red"


statusTextColor : SessionStatus -> String
statusTextColor status =
    case status of
        Waiting ->
            "orange"

        Ready ->
            "blue bg-light-blue"

        Overdue ->
            "red bg-washed-red"


statusBorderColor : SessionStatus -> String
statusBorderColor status =
    case status of
        Waiting ->
            "b--orange"

        Ready ->
            "b--blue"

        Overdue ->
            "b--red"


formatTimeAgo : Time.Posix -> String
formatTimeAgo time =
    -- Simplified time formatting - you'd want a proper time library
    "2h ago"
