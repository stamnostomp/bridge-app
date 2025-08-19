module Main exposing (..)

import Browser
import Html exposing (Html)
import Pages.Dashboard as Dashboard
import Pages.Session as Session
import Types.Session exposing (Session)



-- MAIN


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }



-- MODEL


type Page
    = DashboardPage
    | SessionPage Session


type alias Model =
    { currentPage : Page
    , dashboard : Dashboard.Model
    , session : Maybe Session.Model
    }


init : Model
init =
    { currentPage = DashboardPage
    , dashboard = Dashboard.init
    , session = Nothing
    }



-- UPDATE


type Msg
    = DashboardMsg Dashboard.Msg
    | SessionMsg Session.Msg
    | NavigateToSession Session
    | NavigateToDashboard


update : Msg -> Model -> Model
update msg model =
    case msg of
        DashboardMsg dashboardMsg ->
            let
                updatedDashboard =
                    Dashboard.update dashboardMsg model.dashboard
            in
            -- Check if a session was clicked
            case dashboardMsg of
                Dashboard.SessionClicked sessionId ->
                    -- Find the session and navigate to it
                    let
                        allSessions =
                            updatedDashboard.sessions ++ updatedDashboard.resolvedSessions

                        maybeSession =
                            findSessionById sessionId allSessions
                    in
                    case maybeSession of
                        Just session ->
                            { model
                                | currentPage = SessionPage session
                                , session = Just (Session.init session)
                                , dashboard = updatedDashboard
                            }

                        Nothing ->
                            { model | dashboard = updatedDashboard }

                _ ->
                    { model | dashboard = updatedDashboard }

        SessionMsg sessionMsg ->
            case model.session of
                Just sessionModel ->
                    let
                        updatedSession =
                            Session.update sessionMsg sessionModel
                    in
                    -- Check if we need to navigate back to dashboard
                    case sessionMsg of
                        Session.BackToDashboard ->
                            { model
                                | currentPage = DashboardPage
                                , session = Nothing
                            }

                        _ ->
                            { model | session = Just updatedSession }

                Nothing ->
                    model

        NavigateToSession session ->
            { model
                | currentPage = SessionPage session
                , session = Just (Session.init session)
            }

        NavigateToDashboard ->
            { model
                | currentPage = DashboardPage
                , session = Nothing
            }



-- VIEW


view : Model -> Html Msg
view model =
    case model.currentPage of
        DashboardPage ->
            Html.map DashboardMsg (Dashboard.view model.dashboard)

        SessionPage session ->
            case model.session of
                Just sessionModel ->
                    Html.map SessionMsg (Session.view sessionModel)

                Nothing ->
                    Html.map DashboardMsg (Dashboard.view model.dashboard)



-- HELPERS


findSessionById : String -> List Session -> Maybe Session
findSessionById sessionId sessions =
    sessions
        |> List.filter (\session -> session.id == sessionId)
        |> List.head
