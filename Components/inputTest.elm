module Main exposing (..)

import Html.App as Html
import Components.Input as Input


main =
    Html.beginnerProgram
        { model = Input.initModel "Objective"
        , update = Input.update
        , view = Input.view
        }
