module Components.NewSessionModal exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode



-- VIEW


view : { isOpen : Bool, participantName : String, description : String } -> { onClose : msg, onParticipantNameChange : String -> msg, onDescriptionChange : String -> msg, onSubmit : msg, onModalContentClick : msg } -> Html msg
view state handlers =
    if state.isOpen then
        div
            [ class "fixed absolute--fill flex items-center justify-center"
            , style "background-color" "rgba(0, 0, 0, 0.5)"
            , style "z-index" "1000"
            , onClick handlers.onClose
            ]
            [ div
                [ class "bg-white br3 pa4 ma3"
                , style "width" "100%"
                , style "max-width" "500px"
                , style "box-shadow" "0 10px 25px rgba(0, 0, 0, 0.2)"
                , stopPropagationOn "click" (Decode.map (\_ -> ( handlers.onModalContentClick, True )) (Decode.succeed ()))
                ]
                [ -- Header
                  div
                    [ class "flex justify-between items-center mb4" ]
                    [ h3
                        [ class "ma0 f4 fw5 dark-gray" ]
                        [ text "Start New Session" ]
                    , button
                        [ class "bg-transparent bn pointer gray f3 pa0"
                        , style "line-height" "1"
                        , onClick handlers.onClose
                        ]
                        [ text "×" ]
                    ]

                -- Form
                , div
                    [ class "mb4" ]
                    [ -- Participant Name Field
                      div
                        [ class "mb3" ]
                        [ label
                            [ class "db mb2 f6 fw5 dark-gray" ]
                            [ text "Participant Name" ]
                        , input
                            [ type_ "text"
                            , placeholder "Enter the other person's name"
                            , value state.participantName
                            , onInput handlers.onParticipantNameChange
                            , class "w-100 pa3 ba b--light-gray br2 f6"
                            , style "outline" "none"
                            , style "border-color" "#e0e0e0"
                            ]
                            []
                        ]

                    -- Description Field
                    , div
                        [ class "mb3" ]
                        [ label
                            [ class "db mb2 f6 fw5 dark-gray" ]
                            [ text "Conflict Description" ]
                        , textarea
                            [ placeholder "Briefly describe what this session is about..."
                            , value state.description
                            , onInput handlers.onDescriptionChange
                            , class "w-100 pa3 ba b--light-gray br2 f6"
                            , style "outline" "none"
                            , style "border-color" "#e0e0e0"
                            , style "min-height" "100px"
                            , style "resize" "vertical"
                            ]
                            []
                        ]
                    ]

                -- Action Buttons
                , div
                    [ class "flex justify-end" ]
                    [ button
                        [ class "mr3 pa3 bg-transparent bn pointer gray f6 br2"
                        , onClick handlers.onClose
                        ]
                        [ text "Cancel" ]
                    , button
                        [ class "pa3 bg-dark-gray white bn pointer f6 br2 fw5"
                        , onClick handlers.onSubmit
                        , disabled (String.trim state.participantName == "" || String.trim state.description == "")
                        , style "opacity"
                            (if String.trim state.participantName == "" || String.trim state.description == "" then
                                "0.5"

                             else
                                "1"
                            )
                        ]
                        [ text "Start Session" ]
                    ]
                ]
            ]

    else
        text ""
