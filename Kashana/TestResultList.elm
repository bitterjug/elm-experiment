module Main (..) where

import Effects
import StartApp
import Kashana.ResultList as ResultList


app =
  StartApp.start
    { init = ( ResultList.initModel, Effects.none )
    , update = ResultList.update
    , view = ResultList.view
    , inputs = []
    }


main =
  app.html
