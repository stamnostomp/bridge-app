module Main exposing (..)

import Browser
import Html exposing (Html)
import Pages.Dashboard as Dashboard



-- MAIN


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { dashboard : Dashboard.Model
    }


init : Model
init =
    { dashboard = Dashboard.init
    }



-- UPDATE


type Msg
    = DashboardMsg Dashboard.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        DashboardMsg dashboardMsg ->
            { model | dashboard = Dashboard.update dashboardMsg model.dashboard }



-- VIEW


view : Model -> Html Msg
view model =
    Html.map DashboardMsg (Dashboard.view model.dashboard)
