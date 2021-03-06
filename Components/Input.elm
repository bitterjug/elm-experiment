module Components.Input exposing (Model, Msg, initModel, view, update, saved)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onInput, keyCode, onClick, onBlur)
import Json.Decode as Json


-- Model


type alias Model =
    { name :
        String
        -- name, used for placeholder
    , value :
        String
        -- current stored value
    , input :
        String
        -- new value being entered
    , saving :
        Bool
        -- awaiting server response
    , editing :
        Bool
        -- focussed for editing
    }


initModel : String -> Model
initModel name =
    { name = name
    , value = ""
    , input = ""
    , saving = False
    , editing = False
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

        display =
            h2
                [ highlightStyle
                , onClick Focus
                ]
                [ text
                    <| if model.value == "" then
                        model.name
                       else
                        model.value
                ]

        edit =
            input
                [ type' "text"
                , highlightStyle
                , placeholder model.name
                , value model.input
                , autofocus True
                , name model.name
                , onInput UpdateInput
                , onBlur Latch
                , onKeyDown
                    <| keyMsg
                        [ ( enter, Latch )
                        , ( escape, Reset )
                        ]
                ]
                []
    in
        if model.editing then
            edit
        else
            display



-- Messages


type Msg
    = NoOp
    | UpdateInput String
    | Latch
    | Reset
    | Saved
    | Focus


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
                , editing = False
            }

        Reset ->
            { model
                | input = model.value
                , editing = False
            }

        Saved ->
            { model | saving = False }

        Focus ->
            { model | editing = True }


type alias SavesData =
    Bool
