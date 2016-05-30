module Components.Input exposing (Model, Msg, initModel, view, update, update', saved)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onInput, keyCode)
import Json.Decode as Json


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


keyMsg : List ( Int, Msg ) -> Int -> Msg
keyMsg mapping keycode =
    Dict.fromList mapping
        |> Dict.get keycode
        |> Maybe.withDefault NoOp


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" <| Json.map tagger keyCode


view : Model -> Html Msg
view model =
    let
        highlightStyle =
            -- should probably set classes rather than syles
            style
                <| if model.saving then
                    [ ( "background-color", "orange" ) ]
                   else if model.input /= model.value then
                    [ ( "background-color", "yellow" ) ]
                   else
                    []
    in
        div []
            [ input
                [ type' "text"
                , highlightStyle
                , placeholder model.name
                , value model.input
                , autofocus True
                , name model.name
                , onInput UpdateInput
                , onKeyDown
                    <| keyMsg
                        [ ( enter, Latch )
                        , ( escape, Reset )
                        ]
                ]
                []
            ]



-- Messages


type Msg
    = NoOp
    | UpdateInput String
    | Latch
    | Reset
    | Saved


saved : Model -> Model
saved model =
    update Saved model


update : Msg -> Model -> Model
update msg model =
    case msg of
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


type alias SavesData =
    Bool



{-
   `update'` performs update and also returns the command you provide to save
   data  if we need to save, or no command otherwise.

   This is NOT THE SAME as returning a Cmd Msg because Msg is my local set of
     messages and doesn't include any handling for save events, etc. The client
     has to design that, its not my busiess. So this solution is generic
     w.r.t. message type and lets you proide a save-handler, with it retrns
     when appropriate, or Cmd.none which is generic.
-}


update' : Cmd a -> Msg -> Model -> ( Model, Cmd a )
update' saveCmd msg model =
    let
        cmd' =
            if msg == Latch then
                saveCmd
            else
                Cmd.none
    in
        ( update msg model, cmd' )
