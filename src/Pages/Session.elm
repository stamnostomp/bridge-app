module Pages.Session exposing (Model, Msg(..), init, update, view)

import Components.Navbar as Navbar
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Time
import Types.Session exposing (Round, Session, SessionStatus(..))



-- MODEL


type alias Model =
    { session : Session
    , currentLetter : String
    , isEditing : Bool
    , showPreview : Bool
    , rounds : List Round
    , letterWordCount : Int
    , hasUnsavedChanges : Bool
    , showSubmitConfirm : Bool
    }


init : Session -> Model
init session =
    { session = session
    , currentLetter = getCurrentRoundLetter session
    , isEditing = session.status == Ready
    , showPreview = False
    , rounds = mockRounds session.id
    , letterWordCount = wordCount (getCurrentRoundLetter session)
    , hasUnsavedChanges = False
    , showSubmitConfirm = False
    }



-- UPDATE


type Msg
    = LetterChanged String
    | ToggleEdit
    | SaveDraft
    | SubmitLetter
    | TogglePreview
    | BackToDashboard
    | ConfirmSubmit
    | CancelSubmit
    | RevealRound Int
    | NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        LetterChanged text ->
            { model
                | currentLetter = text
                , letterWordCount = wordCount text
                , hasUnsavedChanges = True
            }

        ToggleEdit ->
            { model | isEditing = not model.isEditing }

        SaveDraft ->
            -- In a real app, this would save to backend
            { model | hasUnsavedChanges = False }

        SubmitLetter ->
            { model | showSubmitConfirm = True }

        ConfirmSubmit ->
            let
                updatedSession =
                    { session = model.session
                    , status = Waiting -- Change status after submitting
                    }
            in
            { model
                | showSubmitConfirm = False
                , isEditing = False
                , hasUnsavedChanges = False
                , session = updatedSession.session
            }

        CancelSubmit ->
            { model | showSubmitConfirm = False }

        TogglePreview ->
            { model | showPreview = not model.showPreview }

        BackToDashboard ->
            -- This would trigger navigation in the main app
            model

        RevealRound roundNumber ->
            let
                updatedRounds =
                    List.map
                        (\round ->
                            if round.roundNumber == roundNumber then
                                { round | isRevealed = True }

                            else
                                round
                        )
                        model.rounds
            in
            { model | rounds = updatedRounds }

        NoOp ->
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
            [ class "pa4" ]
            [ -- Header
              viewSessionHeader model
            , div
                [ class "flex"
                , style "gap" "2rem"
                ]
                [ -- Main content area
                  div
                    [ class "flex-auto" ]
                    [ viewCurrentRound model
                    ]

                -- Sidebar
                , div
                    [ class "w-30" ]
                    [ viewRoundsHistory model
                    , viewSessionInfo model
                    ]
                ]
            ]

        -- Confirmation Modal
        , viewSubmitConfirmation model
        ]


viewSessionHeader : Model -> Html Msg
viewSessionHeader model =
    div
        [ class "mb4 pb3 bb b--light-gray" ]
        [ div
            [ class "flex justify-between items-start" ]
            [ div []
                [ h1
                    [ class "ma0 mb2 f3 fw5 dark-gray" ]
                    [ text ("Session with " ++ model.session.participantName) ]
                , p
                    [ class "ma0 f5 gray lh-copy" ]
                    [ text model.session.description ]
                ]
            , button
                [ class "bg-light-gray gray pa2 br2 bn pointer f6"
                , onClick BackToDashboard
                ]
                [ text "← Back to Dashboard" ]
            ]
        ]


viewCurrentRound : Model -> Html Msg
viewCurrentRound model =
    div
        [ class "bg-white br3 pa4 shadow-2" ]
        [ -- Round header
          div
            [ class "mb4 pb3 bb b--near-white" ]
            [ div
                [ class "flex justify-between items-center mb2" ]
                [ h2
                    [ class "ma0 f4 fw5 dark-gray" ]
                    [ text ("Round " ++ String.fromInt model.session.currentRound ++ " of " ++ String.fromInt model.session.totalRounds) ]
                , div
                    [ class "flex items-center" ]
                    [ viewStatusBadge model.session.status
                    , if model.hasUnsavedChanges then
                        span
                            [ class "ml3 f7 orange" ]
                            [ text "• Unsaved changes" ]

                      else
                        text ""
                    ]
                ]
            , p
                [ class "ma0 f6 gray" ]
                [ text
                    (case model.session.status of
                        Ready ->
                            "It's your turn. Write your letter for this round."

                        Waiting ->
                            "Waiting for " ++ model.session.participantName ++ " to submit their letter."

                        Overdue ->
                            model.session.participantName ++ "'s response is overdue."
                    )
                ]
            ]

        -- Writing interface
        , case model.session.status of
            Ready ->
                viewWritingInterface model

            Waiting ->
                viewWaitingInterface model

            Overdue ->
                viewOverdueInterface model
        ]


viewWritingInterface : Model -> Html Msg
viewWritingInterface model =
    div []
        [ -- Toolbar
          div
            [ class "mb3 flex justify-between items-center" ]
            [ div
                [ class "flex items-center" ]
                [ button
                    [ class
                        (if model.isEditing then
                            "bg-blue white"

                         else
                            "bg-light-gray gray"
                        )
                    , class "pa2 mr2 br2 bn pointer f6"
                    , onClick ToggleEdit
                    ]
                    [ text
                        (if model.isEditing then
                            "Writing"

                         else
                            "Reading"
                        )
                    ]
                , button
                    [ class
                        (if model.showPreview then
                            "bg-blue white"

                         else
                            "bg-light-gray gray"
                        )
                    , class "pa2 br2 bn pointer f6"
                    , onClick TogglePreview
                    ]
                    [ text "Preview" ]
                ]
            , div
                [ class "flex items-center" ]
                [ span
                    [ class "f7 gray mr3" ]
                    [ text (String.fromInt model.letterWordCount ++ " words") ]
                , if model.hasUnsavedChanges then
                    button
                        [ class "bg-orange white pa2 mr2 br2 bn pointer f6"
                        , onClick SaveDraft
                        ]
                        [ text "Save Draft" ]

                  else
                    text ""
                , button
                    [ class "bg-dark-gray white pa2 br2 bn pointer f6"
                    , onClick SubmitLetter
                    , disabled (String.trim model.currentLetter == "")
                    ]
                    [ text "Submit Letter" ]
                ]
            ]

        -- Letter content
        , if model.showPreview then
            viewLetterPreview model.currentLetter

          else if model.isEditing then
            viewLetterEditor model

          else
            viewLetterPreview model.currentLetter
        ]


viewLetterEditor : Model -> Html Msg
viewLetterEditor model =
    div
        [ class "ba b--light-gray br2" ]
        [ textarea
            [ placeholder "Write your letter here...\n\nTips:\n• Be honest about your perspective\n• Focus on specific behaviors, not character\n• Express how the situation affects you\n• Avoid accusatory language\n• Ask clarifying questions"
            , value model.currentLetter
            , onInput LetterChanged
            , class "w-100 pa3 bn br2 f5 lh-copy"
            , style "min-height" "400px"
            , style "resize" "vertical"
            , style "outline" "none"
            , style "font-family" "inherit"
            ]
            []
        ]


viewLetterPreview : String -> Html Msg
viewLetterPreview content =
    div
        [ class "ba b--light-gray br2 pa3"
        , style "min-height" "400px"
        , style "background-color" "#fafafa"
        ]
        [ if String.trim content == "" then
            p
                [ class "gray f5 i" ]
                [ text "Your letter will appear here..." ]

          else
            div
                [ class "f5 lh-copy dark-gray" ]
                [ content
                    |> String.split "\n"
                    |> List.map (\line -> p [ class "ma0 mb3" ] [ text line ])
                    |> div []
                ]
        ]


viewWaitingInterface : Model -> Html Msg
viewWaitingInterface model =
    div
        [ class "tc pa5" ]
        [ div
            [ class "mb4" ]
            [ div
                [ class "br-100 bg-orange white flex items-center justify-center ma-auto mb3"
                , style "width" "80px"
                , style "height" "80px"
                ]
                [ span [ class "f3" ] [ text "..." ] ]
            ]
        , h3
            [ class "ma0 mb3 f4 fw5 dark-gray" ]
            [ text "Letter Submitted!" ]
        , p
            [ class "ma0 mb4 f5 gray lh-copy" ]
            [ text ("Waiting for " ++ model.session.participantName ++ " to submit their letter for this round.") ]
        , p
            [ class "ma0 f6 light-silver" ]
            [ text "You'll be notified when both letters are ready for exchange." ]
        ]


viewOverdueInterface : Model -> Html Msg
viewOverdueInterface model =
    div
        [ class "tc pa5" ]
        [ div
            [ class "mb4" ]
            [ div
                [ class "br-100 bg-red white flex items-center justify-center ma-auto mb3"
                , style "width" "80px"
                , style "height" "80px"
                ]
                [ span [ class "f3" ] [ text "!" ] ]
            ]
        , h3
            [ class "ma0 mb3 f4 fw5 dark-gray" ]
            [ text "Response Overdue" ]
        , p
            [ class "ma0 mb4 f5 gray lh-copy" ]
            [ text (model.session.participantName ++ "'s response is overdue. You may want to send them a reminder.") ]
        ]


viewRoundsHistory : Model -> Html Msg
viewRoundsHistory model =
    div
        [ class "bg-white br3 pa3 mb3 shadow-2" ]
        [ h3
            [ class "ma0 mb3 f5 fw5 dark-gray" ]
            [ text "Rounds History" ]
        , div []
            (List.map (viewRoundSummary model.session.currentRound) model.rounds)
        ]


viewRoundSummary : Int -> Round -> Html Msg
viewRoundSummary currentRound round =
    div
        [ class
            (if round.roundNumber == currentRound then
                "pa3 mb2 bg-blue white br2"

             else if round.roundNumber < currentRound then
                "pa3 mb2 bg-near-white br2"

             else
                "pa3 mb2 bg-light-gray gray br2"
            )
        ]
        [ div
            [ class "flex justify-between items-center mb2" ]
            [ span
                [ class "f6 fw5" ]
                [ text ("Round " ++ String.fromInt round.roundNumber) ]
            , if round.roundNumber < currentRound && not round.isRevealed then
                button
                    [ class "f7 pa1 bn br2 pointer bg-white dark-gray"
                    , onClick (RevealRound round.roundNumber)
                    ]
                    [ text "View" ]

              else
                text ""
            ]
        , if round.isRevealed || round.roundNumber == currentRound then
            div
                [ class "f7" ]
                [ div
                    [ class "mb1" ]
                    [ text
                        (if round.yourLetter /= Nothing then
                            "Your letter: Complete"

                         else
                            "Your letter: Pending"
                        )
                    ]
                , div []
                    [ text
                        (if round.theirLetter /= Nothing then
                            "Their letter: Complete"

                         else
                            "Their letter: Pending"
                        )
                    ]
                ]

          else
            p
                [ class "ma0 f7 o-60" ]
                [ text "Letters exchanged" ]
        ]


viewSessionInfo : Model -> Html Msg
viewSessionInfo model =
    div
        [ class "bg-white br3 pa3 shadow-2" ]
        [ h3
            [ class "ma0 mb3 f5 fw5 dark-gray" ]
            [ text "Session Info" ]
        , div
            [ class "f6 gray" ]
            [ div
                [ class "mb2" ]
                [ strong [] [ text "Participant: " ]
                , text model.session.participantName
                ]
            , div
                [ class "mb2" ]
                [ strong [] [ text "Started: " ]
                , text "2 days ago"
                ]
            , div
                [ class "mb2" ]
                [ strong [] [ text "Last activity: " ]
                , text "3 hours ago"
                ]
            , div
                [ class "mb3" ]
                [ strong [] [ text "Progress: " ]
                , text (String.fromInt model.session.currentRound ++ "/" ++ String.fromInt model.session.totalRounds ++ " rounds")
                ]
            , div
                [ class "pt3 bt b--near-white" ]
                [ h4
                    [ class "ma0 mb2 f6 fw5 dark-gray" ]
                    [ text "Writing Tips" ]
                , ul
                    [ class "ma0 pl3 f7 gray lh-copy" ]
                    [ li [ class "mb1" ] [ text "Be specific about behaviors" ]
                    , li [ class "mb1" ] [ text "Use 'I' statements" ]
                    , li [ class "mb1" ] [ text "Ask open-ended questions" ]
                    , li [ class "mb1" ] [ text "Avoid blame language" ]
                    ]
                ]
            ]
        ]


viewStatusBadge : SessionStatus -> Html Msg
viewStatusBadge status =
    span
        [ class
            (case status of
                Ready ->
                    "f7 ph2 pv1 br3 blue b--blue"

                Waiting ->
                    "f7 ph2 pv1 br3 orange b--orange"

                Overdue ->
                    "f7 ph2 pv1 br3 red b--red"
            )
        , style "border" "1px solid"
        ]
        [ text
            (case status of
                Ready ->
                    "Your Turn"

                Waiting ->
                    "Waiting"

                Overdue ->
                    "Overdue"
            )
        ]


viewSubmitConfirmation : Model -> Html Msg
viewSubmitConfirmation model =
    if model.showSubmitConfirm then
        div
            [ class "fixed absolute--fill flex items-center justify-center"
            , style "background-color" "rgba(0, 0, 0, 0.5)"
            , style "z-index" "1000"
            ]
            [ div
                [ class "bg-white br3 pa4 ma3"
                , style "width" "100%"
                , style "max-width" "400px"
                , style "box-shadow" "0 10px 25px rgba(0, 0, 0, 0.2)"
                ]
                [ h3
                    [ class "ma0 mb3 f4 fw5 dark-gray" ]
                    [ text "Submit Letter?" ]
                , p
                    [ class "ma0 mb4 f5 gray lh-copy" ]
                    [ text "Once submitted, you won't be able to edit this letter. Make sure you're happy with it!" ]
                , div
                    [ class "flex justify-end" ]
                    [ button
                        [ class "mr3 pa3 bg-transparent bn pointer gray f6 br2"
                        , onClick CancelSubmit
                        ]
                        [ text "Cancel" ]
                    , button
                        [ class "pa3 bg-dark-gray white bn pointer f6 br2 fw5"
                        , onClick ConfirmSubmit
                        ]
                        [ text "Submit Letter" ]
                    ]
                ]
            ]

    else
        text ""



-- HELPERS


getCurrentRoundLetter : Session -> String
getCurrentRoundLetter session =
    -- In a real app, this would fetch the current round's letter from backend
    ""


wordCount : String -> Int
wordCount text =
    text
        |> String.trim
        |> String.split " "
        |> List.filter (\word -> not (String.isEmpty (String.trim word)))
        |> List.length


mockRounds : String -> List Round
mockRounds sessionId =
    [ { roundNumber = 1
      , yourLetter = Just "Sample letter content..."
      , theirLetter = Just "Their response..."
      , isRevealed = True
      , submittedAt = Just (Time.millisToPosix 1234567890000)
      }
    , { roundNumber = 2
      , yourLetter = Just "Second round letter..."
      , theirLetter = Nothing
      , isRevealed = False
      , submittedAt = Just (Time.millisToPosix 1234567890000)
      }
    , { roundNumber = 3
      , yourLetter = Nothing
      , theirLetter = Nothing
      , isRevealed = False
      , submittedAt = Nothing
      }
    ]
