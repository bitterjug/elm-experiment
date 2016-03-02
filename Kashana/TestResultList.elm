module Main (..) where

import Effects
import StartApp
import Kashana.ResultList as ResultList


update : ResultList.Action -> ResultList.Model -> ( ResultList.Model, Effects.Effects action )
update act model =
  let
    model' =
      ResultList.update act model
  in
    ( model', Effects.none )


app =
  StartApp.start
    { init = ( ResultList.initModel, Effects.none )
    , update = update
    , view = ResultList.view
    , inputs = []
    }


main =
  app.html
