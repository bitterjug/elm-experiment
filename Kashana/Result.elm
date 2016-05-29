module Kashana.Result exposing (..)

import Components.Input as Input
import Html exposing (..)
import Html.App as App


--import Task
--import Time


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



{--
saveData : Model -> Effects.Effects Action
saveData model =
    -- simulate http request with sleep
    -- needs the whole model which I'm just logging for the moment
    always
        (Task.sleep Time.second
            |> Task.map (always Saved)
            |> Effects.task
        )
        (Debug.log "saving" model)

--}
-- update : Msg -> Model -> ( Model, Cmd Msg )


update msg model =
    {--
    let
        effect act newModel =
            if Input.savesData act then
                saveData newModel
            else
                Effects.none
    in
                --}
    case msg of
        NoOp ->
            model ! []

        UpdateName msg' ->
            { model | name = Input.update msg' model.name } ! []

        UpdateDescription msg' ->
            { model | description = Input.update msg' model.description } ! []

        _ ->
            model ! []



{--

        Saved ->
            ( { model
                | name = Input.update Input.Saved model.name
                , description = Input.update Input.Saved model.description
              }
            , Effects.none
            )
            --}
