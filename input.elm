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

onEnter : Address Action -> Action -> Attribute
onEnter address action =
  on "keydown"
    (Json.customDecoder keyCode is13)
    (\_ -> Signal.message address action)


is13 : Int -> Result String ()
is13 code = 
  if code == 13 then Ok () else Err "Some other code" 
  -- customDecoder requires the result to be `Result String b`
  -- othrerwise we could just unit for both success and failure hre


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
      , onEnter address Latch
      ] [],
      div [] [ 
        text <| "Debug input: " ++ model.input ++ " value:" ++ model.value
      ]
    ]

-- Action

type Action 
  = NoOp 
  | UpdateInput String
  | Latch


update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    UpdateInput s -> { model | input = s }
    Latch -> { model | value = model.input, input = "" }
