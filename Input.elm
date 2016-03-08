module Input (..) where

import Dict
import Html exposing (..)
import Html.Events exposing (onClick, on, targetValue, onKeyPress, keyCode)
import Html.Attributes exposing (..)
import Json.Decode as Json
import Signal exposing (Address)


-- Model


type alias Model =
  { name :
      -- name, used for placeholder
      String
  , value :
      -- current stored vale
      String
  , input :
      -- new value being entered
      String
  , saving :
      -- awaiting server response
      Bool
  }


initModel : String -> Model
initModel name =
  { name = name
  , value = ""
  , input = ""
  , saving = False
  }



-- View


enter =
  13


escape =
  27


type alias KeyMap =
  Dict.Dict Int Action


keys : KeyMap
keys =
  Dict.fromList
    [ ( enter, Latch )
    , ( escape, Reset )
    ]


keyMatch : KeyMap -> Int -> Result String Action
keyMatch keymap code =
  Result.fromMaybe "Unrecognised key" (Dict.get code keymap)


onKey : KeyMap -> Address Action -> Attribute
onKey keymap address =
  on
    "keydown"
    (Json.customDecoder keyCode (keyMatch keymap))
    (\action -> Signal.message address action)


view : Address Action -> Model -> Html
view address model =
  let
    highlightStyle =
      style
        <| if model.saving then
            [ ( "background-color", "orange" ) ]
           else if model.input /= model.value then
            [ ( "background-color", "yellow" ) ]
           else
            []
  in
    div
      []
      [ input
          [ type' "text"
          , highlightStyle
          , placeholder model.name
          , value model.input
          , name model.name
          , autofocus True
          , on "input" targetValue (Signal.message address << UpdateInput)
          , onKey keys address
          ]
          []
      ]



-- Action


type Action
  = NoOp
  | UpdateInput String
  | Latch
  | Reset
  | Saved


savesData : Action -> Bool
savesData =
  (==) Latch


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    UpdateInput s ->
      { model | input = s }

    Latch ->
      { model
        | value = model.input
        , saving = True
      }

    Reset ->
      { model | input = model.value }

    Saved ->
      { model | saving = False }
