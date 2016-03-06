module Kashana.Result (..) where

import Effects
import Input
import Html exposing (..)
import Signal exposing (Address)
import Task


-- Model


type alias Model =
  { name : Input.Model
  , description : Input.Model
  }


initModel =
  { name = Input.initModel "Name"
  , description = Input.initModel "Description"
  }



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
  | Save
  | NoOp


saveData : Address Action -> Effects.Effects Action
saveData address =
  Effects.task <| Task.map (always NoOp) <| Signal.send address Save


update : Address Action -> Action -> Model -> ( Model, Effects.Effects Action )
update add action model =
  let
    effect act =
      if Input.savesData act then
        saveData add
      else
        Effects.none
  in
    case action of
      NoOp ->
        ( model, Effects.none )

      UpdateName act ->
        ( { model | name = Input.update act model.name }
        , effect act
        )

      UpdateDescription act ->
        ( { model | description = Input.update act model.description }
        , effect act
        )

      Save ->
        ( model
        , Debug.log "Saving..." Effects.none
          -- sleep 100 and, on success, send a "create" to the list
        )
