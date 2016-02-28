module Kashana.ResultList where

import Html exposing (..)
import Signal exposing (Address)

import Kashana.Result as Res

-- Model

type alias ID = Int

type alias Model = 
  { results : List (ID, Res.Model)
  , placeholder : Res.Model
  , nextId : ID
  }


initModel : Model
initModel = 
  { results = []
  , placeholder = Res.initModel
  , nextId = 1 
  }

-- View

viewResult : Signal.Address Action -> (ID, Res.Model) -> Html
viewResult address (id, result) = 
  Res.view (Signal.forwardTo address (Update id)) result


view  : Address Action -> Model -> Html
view address model = 
  let
      results = List.map (viewResult address) model.results
      placeholder = Res.view (Signal.forwardTo address Create) model.placeholder
      itemify el = li [] [ el ]
  in
      ul [] (List.map itemify <| results ++ [ placeholder ])
    
-- Action

type Action
    = NoOp
    | Update Int Res.Action
    | Create Res.Action


update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    Create act -> { model | placeholder = Res.update act model.placeholder }
    Update id act -> 
      let updateResult (resId, result) = 
          if resId == id
            then (resId, Res.update act result)
            else (resId, result)
      in { model | results = List.map updateResult model.results }
