import Html exposing (..)
import Html.Events exposing (onClick, on, targetValue, onKeyPress, keyCode)
import Html.Attributes exposing (..)
import Json.Decode as Json
import Signal exposing (Address)
import StartApp.Simple as StartApp

import Debug exposing (log)

-- TODO: Enter -> latch input in value, Escape -> Discard input, display value


main =
  StartApp.start 
    { model = initModel "Objective" 
    , view = view
    , update = update 
    }

-- Model

type alias Model =
  { name: String  -- name, used for placeholder
  , value: String  -- current stored vale
  , input: String  -- new value being entered
  }

initModel : String -> Model
initModel name = 
  { name = name
  , value = ""
  , input = ""
  }  

-- View

type alias KeyMatch = Int -> Result String ()

isKey : Int -> KeyMatch
isKey target = 
  \ code -> log (toString target ++ "==" ++ (toString code) ) (if code == target then Ok () else Err "Some other code")

enter : KeyMatch
enter = isKey 13

escape : KeyMatch
escape = isKey 27

onKey : KeyMatch -> Address Action -> Action -> Attribute
onKey keyMatch address action =
  on "keydown"
    (Json.customDecoder keyCode keyMatch)
    (\_ -> Signal.message address action)


view : Address Action -> Model -> Html
view address model =
  div []
    [ input
      [ type' "text"
      , placeholder model.name
      , value model.input
      , name model.name
      , autofocus True
      , on "input" targetValue (Signal.message address << UpdateInput)
      , onKey enter address Latch
      , onKey escape address Reset
      ] [],
      div [] [ 
        text <| "Debug input: " ++ model.input,
        br [][],
        text <| " value:" ++ model.value
      ]
    ]

-- Action

type Action 
  = NoOp 
  | UpdateInput String
  | Latch
  | Reset


update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    UpdateInput s -> { model | input = s }
    Latch -> { model | value = model.input, input = "" }
    Reset -> { model | input = model.value }
