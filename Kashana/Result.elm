module Kashana.Result (..) where

import Effects
import Input
import Html exposing (..)
import Signal exposing (Address)


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
    [ Input.view (Signal.forwardTo address Name) model.name
    , Input.view (Signal.forwardTo address Description) model.description
    ]



-- Action


type Action
  = Name Input.Action
  | Description Input.Action


update : Action -> Model -> ( Model, Effects.Effects Action )
update action model =
  case action of
    Name act ->
      ( { model | name = Input.update act model.name }
      , Effects.none
      )

    Description act ->
      ( { model | description = Input.update act model.description }
      , Effects.none
      )
