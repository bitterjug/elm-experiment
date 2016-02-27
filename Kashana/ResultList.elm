module Kashana.ResultList where

import Html exposing (..)
import Signal exposing (Address)

import Kashana.Result as Res

-- Model

type alias Model = 
  { results : List Res.Model
  , placeholder : Res.Model
  , nextId : Int
  }


initModel : Model
initModel = 
  { results = []
  , placeholder = Res.initModel
  , nextId = 1 
  }

-- View

viewResult : Signal.Address Action -> Res.Model -> Html
viewResult address result = 
  li [] [
    Res.view (Signal.forwardTo address <| Update result.id) result
  ]


view  : Address Action -> Model -> Html
view address model = 
  let 
      results = model.results ++ [ model.placeholder ]
      resultItems = List.map (viewResult address) results
  in
      ul [] resultItems
    
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
      let updateResult res = 
          if res.id == id
            then Res.update act res
            else res
      in 
          { model | results = List.map updateResult model.results }
