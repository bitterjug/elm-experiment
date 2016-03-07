module Main (..) where

import Effects
import StartApp
import Task
import Kashana.ResultList as ResultList


app =
  StartApp.start
    { init = ResultList.init
    , update = ResultList.update
    , view = ResultList.view
    , inputs = []
    }


port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  -- Signal.map (Debug.log "task")
  app.tasks


main =
  app.html
