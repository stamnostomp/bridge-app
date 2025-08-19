module Components.SessionCard exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time
import Types.Session exposing (Session, SessionStatus(..), sessionStatusColor, sessionStatusToString)



-- VIEW


view : Session -> (String -> msg) -> Html msg
view session onSessionClick =
    div
        [ class "bg-white br2 session-card pointer"
        , style "width" "220px"
        , style "height" "180px"
        , style "margin" "12px"
        , style "box-shadow" "0 2px 8px rgba(0,0,0,0.1)"
        , style "border" "1px solid rgba(0,0,0,0.1)"
        , style "cursor" "pointer"
        , onClick (onSessionClick session.id)
        ]
        [ -- Header with participant name and status indicator
          div
            [ class "bg-near-white br2 br--top pa2 flex justify-between items-center"
            , style "height" "35px"
            , style "border-bottom" "1px solid rgba(0,0,0,0.05)"
            ]
            [ h4
                [ class "ma0 f6 fw5 dark-gray truncate"
                , style "max-width" "160px"
                ]
                [ text ("with " ++ session.participantName) ]
            , div
                [ class "br-100 flex-shrink-0"
                , style "width" "8px"
                , style "height" "8px"
                , style "background-color" (statusColor session.status)
                ]
                []
            ]

        -- Content area
        , div
            [ class "pa3 flex flex-column relative"
            , style "height" "145px"
            ]
            [ div [ class "flex-auto" ]
                [ p
                    [ class "ma0 mb2 f6 gray fw5" ]
                    [ text ("Round " ++ String.fromInt session.currentRound ++ " of " ++ String.fromInt session.totalRounds) ]
                , p
                    [ class "ma0 mb1 f7 light-silver" ]
                    [ text ("Started: " ++ formatTimeAgo session.startedAt) ]
                , p
                    [ class "ma0 mb2 f7 light-silver" ]
                    [ text ("Last activity: " ++ formatTimeAgo session.lastActivity) ]
                , p
                    [ class "ma0 f7 gray lh-copy"
                    , style "overflow" "hidden"
                    , style "display" "-webkit-box"
                    , style "-webkit-line-clamp" "2"
                    , style "-webkit-box-orient" "vertical"
                    , style "max-height" "2.8em"
                    , style "line-height" "1.4"
                    , style "padding-right" "80px"
                    , style "margin-bottom" "8px"
                    ]
                    [ text session.description ]
                ]

            -- Status badge (positioned absolutely in bottom-right)
            , div
                [ class "absolute"
                , style "bottom" "12px"
                , style "right" "12px"
                ]
                [ span
                    [ class ("f7 ph2 pv1 br3 " ++ statusClasses session.status)
                    , style "border" "1px solid"
                    , style "font-size" "10px"
                    , style "line-height" "1"
                    , style "flex-shrink" "0"
                    ]
                    [ text (sessionStatusToString session.status) ]
                ]
            ]
        ]



-- HELPERS


statusColor : SessionStatus -> String
statusColor status =
    case status of
        Waiting ->
            "#ffa500"

        Ready ->
            "#4a90e2"

        Overdue ->
            "#ff6b6b"


statusClasses : SessionStatus -> String
statusClasses status =
    case status of
        Waiting ->
            "gray b--light-gray"

        Ready ->
            "blue b--blue"

        Overdue ->
            "red b--red"


formatTimeAgo : Time.Posix -> String
formatTimeAgo time =
    -- Simplified - in real app you'd calculate actual time differences
    "2h ago"
