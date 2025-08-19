module Pages.Dashboard exposing (Model, Msg, init, update, view)

import Components.Navbar as Navbar
import Components.SessionCard as SessionCard
import Components.Tabs as Tabs
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time
import Types.Session exposing (Session, SessionStatus(..))



-- MODEL


type alias Model =
    { sessions : List Session
    , activeTab : Tabs.Tab
    , resolvedSessions : List Session
    }


init : Model
init =
    { sessions = mockSessions
    , activeTab = Tabs.Open
    , resolvedSessions = mockResolvedSessions
    }



-- UPDATE


type Msg
    = TabChanged Tabs.Tab
    | NewSessionClicked
    | SessionClicked String


update : Msg -> Model -> Model
update msg model =
    case msg of
        TabChanged tab ->
            { model | activeTab = tab }

        NewSessionClicked ->
            -- TODO: Navigate to new session page
            model

        SessionClicked sessionId ->
            -- TODO: Navigate to session page
            model



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "min-vh-100"
        , style "background" "linear-gradient(135deg, #fafafa 0%, #f0f0f0 100%)"
        ]
        [ Navbar.view
        , main_
            [ class "ph4 pv3" ]
            [ -- Header with tabs and new session button
              div
                [ class "flex justify-between items-end mb3" ]
                [ Html.map TabChanged (Tabs.view model.activeTab TabChanged (List.length model.sessions) (List.length model.resolvedSessions))
                , button
                    [ class "bg-dark-gray white ph3 pv2 br3 f6 fw5 bn pointer"
                    , onClick NewSessionClicked
                    ]
                    [ text "+ New Session" ]
                ]

            -- Board area
            , div
                [ class "bg-white-30 br2 pa4 min-h-75"
                , style "min-height" "580px"
                ]
                [ case model.activeTab of
                    Tabs.Open ->
                        viewOpenSessions model.sessions

                    Tabs.Resolved ->
                        viewResolvedSessions model.resolvedSessions
                ]

            -- Status legend and stats
            , div
                [ class "flex justify-between items-center mt3" ]
                [ viewStatusLegend
                , p
                    [ class "ma0 f6 gray" ]
                    [ text (String.fromInt (List.length model.sessions) ++ " active sessions • " ++ String.fromInt (readySessionsCount model.sessions) ++ " ready for exchange") ]
                ]
            ]
        ]


viewOpenSessions : List Session -> Html Msg
viewOpenSessions sessions =
    div
        [ class "flex flex-wrap" ]
        (List.map (\session -> Html.map (\_ -> SessionClicked session.id) (SessionCard.view session)) sessions
            ++ [ viewNewSessionCard ]
        )


viewResolvedSessions : List Session -> Html Msg
viewResolvedSessions sessions =
    div
        [ class "flex flex-wrap" ]
        (List.map (\session -> Html.map (\_ -> SessionClicked session.id) (SessionCard.view session)) sessions)


viewNewSessionCard : Html Msg
viewNewSessionCard =
    div
        [ class "bg-white br2 ba b--dashed b--light-gray pa0 ma2 w5 h5 flex flex-column items-center justify-center pointer"
        , style "min-height" "160px"
        , onClick NewSessionClicked
        ]
        [ p
            [ class "ma0 f5 gray tc" ]
            [ text "+ Start new" ]
        , p
            [ class "ma0 f5 gray tc" ]
            [ text "session" ]
        ]


viewStatusLegend : Html Msg
viewStatusLegend =
    div
        [ class "flex items-center" ]
        [ span
            [ class "f6 gray mr3" ]
            [ text "Status:" ]
        , div
            [ class "flex items-center mr3" ]
            [ div [ class "w3 h3 br-100 bg-blue mr1" ] []
            , span [ class "f7 gray" ] [ text "Ready" ]
            ]
        , div
            [ class "flex items-center mr3" ]
            [ div [ class "w3 h3 br-100 bg-orange mr1" ] []
            , span [ class "f7 gray" ] [ text "Waiting" ]
            ]
        , div
            [ class "flex items-center" ]
            [ div [ class "w3 h3 br-100 bg-red mr1" ] []
            , span [ class "f7 gray" ] [ text "Overdue" ]
            ]
        ]



-- HELPERS


readySessionsCount : List Session -> Int
readySessionsCount sessions =
    sessions
        |> List.filter (\session -> session.status == Ready)
        |> List.length



-- MOCK DATA


mockSessions : List Session
mockSessions =
    [ { id = "1"
      , participantName = "Alex Chen"
      , currentRound = 3
      , totalRounds = 5
      , startedAt = Time.millisToPosix 1234567890000
      , lastActivity = Time.millisToPosix 1234567890000
      , description = "Workplace disagreement about project timeline and priorities"
      , status = Waiting
      }
    , { id = "2"
      , participantName = "Sarah M."
      , currentRound = 1
      , totalRounds = 3
      , startedAt = Time.millisToPosix 1234567890000
      , lastActivity = Time.millisToPosix 1234567890000
      , description = "Family discussion about holiday planning"
      , status = Ready
      }
    , { id = "3"
      , participantName = "Jordan K."
      , currentRound = 2
      , totalRounds = 4
      , startedAt = Time.millisToPosix 1234567890000
      , lastActivity = Time.millisToPosix 1234567890000
      , description = "Roommate issues regarding shared responsibilities"
      , status = Overdue
      }
    , { id = "4"
      , participantName = "Morgan D."
      , currentRound = 4
      , totalRounds = 5
      , startedAt = Time.millisToPosix 1234567890000
      , lastActivity = Time.millisToPosix 1234567890000
      , description = "Business partnership decision making process"
      , status = Ready
      }
    ]


mockResolvedSessions : List Session
mockResolvedSessions =
    []
