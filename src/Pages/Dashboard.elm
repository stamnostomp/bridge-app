module Pages.Dashboard exposing (Model, Msg, init, update, view)

import Components.Navbar as Navbar
import Components.NewSessionModal as NewSessionModal
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
    , modalState : ModalState
    }


type alias ModalState =
    { isOpen : Bool
    , participantName : String
    , description : String
    , suggestions : List String
    , showSuggestions : Bool
    , selectedSuggestionIndex : Int
    }


init : Model
init =
    { sessions = mockSessions
    , activeTab = Tabs.Open
    , resolvedSessions = mockResolvedSessions
    , modalState =
        { isOpen = False
        , participantName = ""
        , description = ""
        , suggestions = []
        , showSuggestions = False
        , selectedSuggestionIndex = 0
        }
    }



-- UPDATE


type Msg
    = TabChanged Tabs.Tab
    | NewSessionClicked
    | SessionClicked String
    | CloseModal
    | ParticipantNameChanged String
    | DescriptionChanged String
    | CreateSession
    | NoOp
    | SelectSuggestion String
    | HandleKeyDown Int


update : Msg -> Model -> Model
update msg model =
    case msg of
        TabChanged tab ->
            { model | activeTab = tab }

        NewSessionClicked ->
            let
                currentModal =
                    model.modalState

                newModal =
                    { currentModal | isOpen = True }
            in
            { model | modalState = newModal }

        SessionClicked sessionId ->
            -- TODO: Navigate to session page
            model

        CloseModal ->
            let
                currentModal =
                    model.modalState

                newModal =
                    { currentModal
                        | isOpen = False
                        , participantName = ""
                        , description = ""
                        , suggestions = []
                        , showSuggestions = False
                        , selectedSuggestionIndex = 0
                    }
            in
            { model | modalState = newModal }

        ParticipantNameChanged name ->
            let
                currentModal =
                    model.modalState

                filteredSuggestions =
                    filterSuggestions name

                newModal =
                    { currentModal
                        | participantName = name
                        , suggestions = filteredSuggestions
                        , showSuggestions = String.length (String.trim name) > 0 && not (List.isEmpty filteredSuggestions)
                        , selectedSuggestionIndex = 0
                    }
            in
            { model | modalState = newModal }

        SelectSuggestion name ->
            let
                currentModal =
                    model.modalState

                newModal =
                    { currentModal
                        | participantName = name
                        , suggestions = []
                        , showSuggestions = False
                        , selectedSuggestionIndex = 0
                    }
            in
            { model | modalState = newModal }

        HandleKeyDown keyCode ->
            case keyCode of
                -- Arrow Down (40)
                40 ->
                    let
                        currentModal =
                            model.modalState

                        maxIndex =
                            List.length currentModal.suggestions - 1

                        newIndex =
                            Basics.min maxIndex (currentModal.selectedSuggestionIndex + 1)

                        newModal =
                            { currentModal | selectedSuggestionIndex = newIndex }
                    in
                    { model | modalState = newModal }

                -- Arrow Up (38)
                38 ->
                    let
                        currentModal =
                            model.modalState

                        newIndex =
                            Basics.max 0 (currentModal.selectedSuggestionIndex - 1)

                        newModal =
                            { currentModal | selectedSuggestionIndex = newIndex }
                    in
                    { model | modalState = newModal }

                -- Enter (13)
                13 ->
                    let
                        currentModal =
                            model.modalState

                        selectedSuggestion =
                            currentModal.suggestions
                                |> List.drop currentModal.selectedSuggestionIndex
                                |> List.head
                    in
                    case selectedSuggestion of
                        Just suggestion ->
                            let
                                newModal =
                                    { currentModal
                                        | participantName = suggestion
                                        , suggestions = []
                                        , showSuggestions = False
                                        , selectedSuggestionIndex = 0
                                    }
                            in
                            { model | modalState = newModal }

                        Nothing ->
                            model

                -- Escape (27)
                27 ->
                    let
                        currentModal =
                            model.modalState

                        newModal =
                            { currentModal
                                | suggestions = []
                                , showSuggestions = False
                                , selectedSuggestionIndex = 0
                            }
                    in
                    { model | modalState = newModal }

                _ ->
                    model

        DescriptionChanged description ->
            let
                currentModal =
                    model.modalState

                newModal =
                    { currentModal | description = description }
            in
            { model | modalState = newModal }

        CreateSession ->
            if String.trim model.modalState.participantName /= "" && String.trim model.modalState.description /= "" then
                let
                    newSession =
                        createNewSession model.modalState.participantName model.modalState.description

                    newModal =
                        { isOpen = False
                        , participantName = ""
                        , description = ""
                        , suggestions = []
                        , showSuggestions = False
                        , selectedSuggestionIndex = 0
                        }
                in
                { model
                    | sessions = newSession :: model.sessions
                    , modalState = newModal
                }

            else
                model

        NoOp ->
            model



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "min-vh-100"
        , style "background" "linear-gradient(135deg, #fafafa 0%, #f0f0f0 100%)"
        , style "padding-bottom" "2rem"
        ]
        [ Navbar.view
        , main_
            [ class "pa0" ]
            [ -- Tab Navigation Area
              div
                [ class "ph4 pt3 flex justify-between items-end" ]
                [ div
                    [ class "flex" ]
                    [ -- Open tab
                      button
                        [ class
                            (if model.activeTab == Tabs.Open then
                                "bg-white ph3 pv2 f6 fw5 dark-gray ba b--light-gray bn br0"

                             else
                                "bg-white-50 ph3 pv2 f6 gray ba b--light-gray bn br0"
                            )
                        , onClick (TabChanged Tabs.Open)
                        , style "width" "120px"
                        , style "height" "40px"
                        ]
                        [ text ("Open (" ++ String.fromInt (List.length model.sessions) ++ ")") ]

                    -- Resolved tab
                    , button
                        [ class
                            (if model.activeTab == Tabs.Resolved then
                                "bg-white ph3 pv2 f6 fw5 dark-gray ba b--light-gray bn br0"

                             else
                                "bg-white-50 ph3 pv2 f6 gray ba b--light-gray bn br0"
                            )
                        , onClick (TabChanged Tabs.Resolved)
                        , style "width" "120px"
                        , style "height" "40px"
                        ]
                        [ text ("Resolved (" ++ String.fromInt (List.length model.resolvedSessions) ++ ")") ]
                    ]

                -- New Session Button
                , button
                    [ class "bg-dark-gray white ph3 pv2 br3 f6 fw5 bn pointer flex items-center justify-center no-wrap"
                    , onClick NewSessionClicked
                    , style "width" "120px"
                    , style "height" "32px"
                    , style "border-radius" "16px"
                    , style "white-space" "nowrap"
                    ]
                    [ text "+ New Session" ]
                ]

            -- Board area
            , div
                [ class "mh4 mt3 pa4"
                , style "background-color" "rgba(255,255,255,0.3)"
                , style "border" "1px solid rgba(0,0,0,0.05)"
                , style "border-radius" "4px"
                , style "min-height" "500px"
                , style "overflow-x" "auto"
                ]
                [ case model.activeTab of
                    Tabs.Open ->
                        viewOpenSessions model.sessions

                    Tabs.Resolved ->
                        viewResolvedSessions model.resolvedSessions
                ]

            -- Status legend and stats
            , div
                [ class "ph4 pt4 pb4 flex justify-between items-center" ]
                [ viewStatusLegend
                , p
                    [ class "ma0 f6 gray" ]
                    [ text (String.fromInt (List.length model.sessions) ++ " active sessions • " ++ String.fromInt (readySessionsCount model.sessions) ++ " ready for exchange") ]
                ]
            ]

        -- Modal
        , NewSessionModal.view
            model.modalState
            { onClose = CloseModal
            , onParticipantNameChange = ParticipantNameChanged
            , onDescriptionChange = DescriptionChanged
            , onSubmit = CreateSession
            , onModalContentClick = NoOp
            , onSelectSuggestion = SelectSuggestion
            , onKeyDown = HandleKeyDown
            }
        ]


viewOpenSessions : List Session -> Html Msg
viewOpenSessions sessions =
    div
        [ class "flex flex-wrap justify-start"
        ]
        (List.map (\session -> Html.map (\_ -> SessionClicked session.id) (SessionCard.view session)) sessions
            ++ [ viewNewSessionCard ]
        )


viewResolvedSessions : List Session -> Html Msg
viewResolvedSessions sessions =
    div
        [ class "flex flex-wrap justify-start"
        ]
        (List.map (\session -> Html.map (\_ -> SessionClicked session.id) (SessionCard.view session)) sessions)


viewNewSessionCard : Html Msg
viewNewSessionCard =
    div
        [ class "br2 flex flex-column items-center justify-center pointer"
        , style "width" "220px"
        , style "height" "180px"
        , style "margin" "12px"
        , style "border" "2px dashed #ddd"
        , style "opacity" "0.6"
        , onClick NewSessionClicked
        ]
        [ div
            [ class "tc" ]
            [ p
                [ class "ma0 f5 gray" ]
                [ text "+ Start new" ]
            , p
                [ class "ma0 f5 gray" ]
                [ text "session" ]
            ]
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
            [ div
                [ class "br-100 mr1"
                , style "width" "8px"
                , style "height" "8px"
                , style "background-color" "#4a90e2"
                ]
                []
            , span [ class "f7 gray" ] [ text "Ready" ]
            ]
        , div
            [ class "flex items-center mr3" ]
            [ div
                [ class "br-100 mr1"
                , style "width" "8px"
                , style "height" "8px"
                , style "background-color" "#ffa500"
                ]
                []
            , span [ class "f7 gray" ] [ text "Waiting" ]
            ]
        , div
            [ class "flex items-center" ]
            [ div
                [ class "br-100 mr1"
                , style "width" "8px"
                , style "height" "8px"
                , style "background-color" "#ff6b6b"
                ]
                []
            , span [ class "f7 gray" ] [ text "Overdue" ]
            ]
        ]



-- HELPERS


readySessionsCount : List Session -> Int
readySessionsCount sessions =
    sessions
        |> List.filter (\session -> session.status == Ready)
        |> List.length


createNewSession : String -> String -> Session
createNewSession participantName description =
    { id = "new-" ++ String.fromInt (Time.posixToMillis (Time.millisToPosix 0)) -- In a real app, you'd generate a proper ID
    , participantName = participantName
    , currentRound = 1
    , totalRounds = 3
    , startedAt = Time.millisToPosix 1234567890000 -- In a real app, you'd use current time
    , lastActivity = Time.millisToPosix 1234567890000
    , description = description
    , status = Waiting
    }


filterSuggestions : String -> List String
filterSuggestions input =
    let
        lowercaseInput =
            String.toLower (String.trim input)
    in
    if String.length lowercaseInput < 1 then
        []

    else
        suggestedNames
            |> List.filter (\name -> String.contains lowercaseInput (String.toLower name))
            |> List.take 5



-- SUGGESTED NAMES (In a real app, this would come from previous sessions or a user database)


suggestedNames : List String
suggestedNames =
    [ "Alex Chen"
    , "Sarah Mitchell"
    , "Jordan Kim"
    , "Morgan Davis"
    , "Taylor Johnson"
    , "Casey Wilson"
    , "River Martinez"
    , "Jamie Brown"
    , "Sam Thompson"
    , "Quinn Anderson"
    , "Blake Williams"
    , "Drew Garcia"
    , "Avery Miller"
    , "Logan Lee"
    , "Cameron White"
    , "Riley Jones"
    , "Harper Clark"
    , "Sage Rodriguez"
    , "Parker Lewis"
    , "Emery Walker"
    ]



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
