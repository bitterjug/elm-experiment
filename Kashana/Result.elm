module Kashana.Result exposing (..)

import Components.Input as Input
import Html exposing (..)
import Html.App as App
import Task
import Time
import Process


main =
    App.program
        { init = initModel ! []
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- Model


type alias Model =
    { name : Input.Model
    , description : Input.Model
    }


initModel : Model
initModel =
    { name = Input.initModel "Name"
    , description = Input.initModel "Description"
    }



-- View
-- view : Model -> Html Msg


view model =
    div []
        [ App.map UpdateName (Input.view model.name)
        , App.map UpdateDescription (Input.view model.description)
        ]



-- Messages


type Msg
    = UpdateName Input.Msg
    | UpdateDescription Input.Msg
    | Saved
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        saveData : Cmd Msg
        saveData =
            -- simulate http request with sleep
            -- needs the whole model which I'm just logging for the moment
            let
                _ =
                    Debug.log "saving" model
            in
                Process.sleep Time.second
                    |> Task.perform (always NoOp) (always Saved)
    in
        case msg of
            NoOp ->
                model ! []

            UpdateName msg' ->
                let
                    ( name', cmd ) =
                        Input.update' saveData msg' model.name
                in
                    ( { model | name = name' }, cmd )

            UpdateDescription msg' ->
                let
                    ( description', cmd ) =
                        Input.update' saveData msg' model.description
                in
                    ( { model | description = description' }, cmd )

            Saved ->
                { model
                    | name = Input.saved model.name
                    , description = Input.saved model.description
                }
                    ! []
