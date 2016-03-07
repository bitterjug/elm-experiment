module Kashana.ResultList (..) where

import Effects
import Html exposing (..)
import Signal exposing (Address)
import Kashana.Result as Res


-- Model


type alias ID =
  Int


type alias Model =
  { results : List ( ID, Res.Model )
  , placeholder : Res.Model
  , nextId : ID
  }


initModel : Model
initModel =
  { results = []
  , placeholder = Res.initModel
  , nextId = 1
  }


init =
  ( initModel, Effects.none )



-- View


viewResult : Signal.Address Action -> ( ID, Res.Model ) -> Html
viewResult address ( id, result ) =
  Res.view (Signal.forwardTo address (UpdateListItem id)) result


view : Address Action -> Model -> Html
view address model =
  let
    results =
      List.map (viewResult address) model.results

    placeholder =
      Res.view (Signal.forwardTo address UpdatePlaceholder) model.placeholder

    itemify el =
      li [] [ el ]
  in
    ul [] (List.map itemify <| results ++ [ placeholder ])



-- Action


type Action
  = NoOp
  | UpdateListItem Int Res.Action
  | UpdatePlaceholder Res.Action
  | AddNewItem


update : Action -> Model -> ( Model, Effects.Effects Action )
update act model =
  case act of
    NoOp ->
      ( model, Effects.none )

    AddNewItem ->
      ( { model
          | placeholder = Res.initModel
          , results = model.results ++ [ ( model.nextId, model.placeholder ) ]
          , nextId = model.nextId + 1
        }
      , Effects.none
      )

    UpdatePlaceholder act ->
      let
        ( placeholder', effects ) =
          Res.update act model.placeholder
      in
        ( { model | placeholder = placeholder' }
        , Effects.map UpdatePlaceholder effects
        )

    UpdateListItem id act ->
      let
        updateResult ( resId, result ) =
          if resId == id then
            let
              ( result', effects ) =
                Res.update act result
            in
              ( ( resId, result' ), effects )
          else
            ( ( resId, result ), Effects.none )

        -- This Effects marshalling is unsatisfactory, is there a neater way to do it via a mailbox?
        ( results'', effectsList ) =
          List.unzip (List.map updateResult model.results)
      in
        ( { model | results = results'' }
        , Effects.map (UpdateListItem id) (Effects.batch effectsList)
        )
