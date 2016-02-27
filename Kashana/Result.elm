module Kashana.Result where

import Input
import Html exposing (..)
import Signal exposing (Address)


-- Model


type alias Model =
  { id : Maybe Int
  , name : Input.Model
  , description : Input.Model
  }


initModel = 
  { id = Nothing
  , name =  Input.initModel "Name"
  , description =  Input.initModel "Description"
  }


-- View

view : Address Action -> Model -> Html 
view address model =
  div []
  [ Input.view (Signal.forwardTo address Name) model.name
  , Input.view (Signal.forwardTo address Description) model.description
  ]

-- Action

type Action
   = Name Input.Action
   | Description Input.Action


update : Action -> Model -> Model
update action model = 
  case action of
    Name act ->        { model | name        = Input.update act model.name }
    Description act -> { model | description = Input.update act model.description }
