module Main (..) where

import Effects
import StartApp
import Task
import Kashana.Result as Res


app =
  StartApp.start
    { init = Res.init
    , update = Res.update
    , view = Res.view
    , inputs = []
    }


port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  -- Signal.map (Debug.log "task")
  app.tasks


main =
  app.html
