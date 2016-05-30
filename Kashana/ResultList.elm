module Kashana.ResultList exposing (..)

import Html exposing (..)
import Html.App as App
import Kashana.Result as Res


main =
    App.program
        { init = initModel ! []
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- Model


type alias ID =
    Int


type alias Model =
    { results : List ( ID, Res.Model )
    , placeholder : Res.Model
    , nextId : ID
    }


initModel : Model
initModel =
    { results = []
    , placeholder = Res.initModel
    , nextId = 1
    }



-- View


view : Model -> Html Msg
view model =
    let
        viewResult : ( ID, Res.Model ) -> Html Msg
        viewResult ( id, result ) =
            App.map (UpdateListItem id) (Res.view result)

        results =
            List.map viewResult model.results

        placeholder =
            App.map UpdatePlaceholder (Res.view model.placeholder)

        itemify el =
            li [] [ el ]
    in
        ul [] (List.map itemify <| results ++ [ placeholder ])



-- Messages


type Msg
    = NoOp
    | UpdateListItem Int Res.Msg
    | UpdatePlaceholder Res.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        UpdatePlaceholder msg' ->
            let
                ( placeholder', cmd ) =
                    Res.update msg' model.placeholder

                cmd' =
                    Cmd.map UpdatePlaceholder cmd
            in
                if msg' == Res.Saved then
                    -- add new list itme
                    ( { model
                        | results =
                            model.results ++ [ ( model.nextId, placeholder' ) ]
                        , placeholder = Res.initModel
                        , nextId = model.nextId + 1
                      }
                    , cmd'
                    )
                else
                    ( { model | placeholder = placeholder' }, cmd' )

        UpdateListItem id msg' ->
            let
                updateResult ( id', result ) =
                    if id' == id then
                        let
                            ( result', cmd ) =
                                Res.update msg' result
                        in
                            ( ( id', result' ), cmd )
                    else
                        ( ( id', result ), Cmd.none )

                ( results'', cmds ) =
                    List.unzip (List.map updateResult model.results)
            in
                ( { model | results = results'' }
                , Cmd.map (UpdateListItem id) (Cmd.batch cmds)
                )
