module Main (..) where

import Effects
import Task
import Kashana.ResultList exposing (testapp)


-- import Kashana.Result exposing (testapp)


app =
  testapp


port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks


main =
  app.html
