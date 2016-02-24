import Dict
import Html exposing (..)
import Html.Events exposing (onClick, on, targetValue, onKeyPress, keyCode)
import Html.Attributes exposing (..)
import Json.Decode as Json
import Signal exposing (Address)
import StartApp.Simple as StartApp


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

enter = 13
escape = 27

type alias KeyMap = Dict.Dict Int Action

keys : KeyMap
keys = Dict.fromList 
  [ (enter, Latch)
  , (escape, Reset)
  ]

keyMatch : KeyMap -> Int -> Result String Action
keyMatch keymap code = 
  Result.fromMaybe "Unrecognised key" (Dict.get code keymap)

onKey : KeyMap -> Address Action -> Attribute
onKey keymap address =
  on "keydown"
    (Json.customDecoder keyCode (keyMatch keymap))
    (\action -> Signal.message address action)


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
      , onKey keys address
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
