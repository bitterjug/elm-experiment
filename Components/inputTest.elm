module Main exposing (..)

import Html.App as Html
import Components.Input as Input


main =
    Html.program
        { init = Input.initModel "Objective"
        , update = Input.update
        , view = Input.view
        , subscriptions = \_ -> Sub.none
        }
