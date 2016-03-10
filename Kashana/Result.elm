module Kashana.Result (..) where

import Effects
import Components.Input as Input
import Html exposing (..)
import Signal exposing (Address)
import StartApp
import Task
import Time


testapp =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }



-- Model


type alias Model =
  { name : Input.Model
  , description : Input.Model
  }


initModel =
  { name = Input.initModel "Name"
  , description = Input.initModel "Description"
  }


init =
  ( initModel, Effects.none )



-- View


view : Address Action -> Model -> Html
view address model =
  div
    []
    [ Input.view (Signal.forwardTo address UpdateName) model.name
    , Input.view (Signal.forwardTo address UpdateDescription) model.description
    ]



-- Action


type Action
  = UpdateName Input.Action
  | UpdateDescription Input.Action
  | Saved
  | NoOp


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


update : Action -> Model -> ( Model, Effects.Effects Action )
update action model =
  let
    effect act newModel =
      if Input.savesData act then
        saveData newModel
      else
        Effects.none
  in
    case action of
      NoOp ->
        ( model, Effects.none )

      UpdateName act ->
        let
          model' =
            { model | name = Input.update act model.name }
        in
          ( model'
          , effect act model'
          )

      UpdateDescription act ->
        let
          model' =
            { model | description = Input.update act model.description }
        in
          ( model'
          , effect act model'
          )

      Saved ->
        ( { model
            | name = Input.update Input.Saved model.name
            , description = Input.update Input.Saved model.description
          }
        , Effects.none
        )
