import Html exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Html.Attributes exposing (..)
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
      ] [],
      div [] [ text <| "Debug: " ++ model.input ]
    ]

-- Action

type Action 
  = NoOp 
  | UpdateInput String


update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    UpdateInput s -> { model | input = s }
