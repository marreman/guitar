port module Main exposing (main)

import Browser
import Element
    exposing
        ( Color
        , Element
        , centerX
        , centerY
        , column
        , el
        , paragraph
        , rgb
        , spacing
        , text
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import GuitarString exposing (GuitarString)
import Html exposing (Html)
import Note exposing (Note)
import Random


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { position : Maybe ( GuitarString, Note )
    , speed : Int
    , listening : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { position = Nothing, speed = 1, listening = False }
    , Cmd.none
    )


generateRandomPosition : Cmd Msg
generateRandomPosition =
    Random.pair GuitarString.generator Note.generator
        |> Random.generate GotRandomPosition


type Msg
    = GotRandomPosition ( GuitarString, Note )
    | GotFrequencyChange (Maybe Float)
    | Start
    | Stop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotRandomPosition position ->
            ( { model | position = Just position }, Cmd.none )

        Start ->
            ( { model | listening = True }
            , if not model.listening then
                Cmd.batch
                    [ startListeningForFrequencyChanges ()
                    , generateRandomPosition
                    ]

              else
                Cmd.none
            )

        Stop ->
            ( { model | listening = False }
            , stopListeningForFrequencyChanges ()
            )

        GotFrequencyChange frequency ->
            let
                wantedNote =
                    Maybe.map Tuple.second model.position

                playedNote =
                    Maybe.andThen Note.fromFrequency frequency

                playedTheWantedNote =
                    Maybe.map2 (==) playedNote wantedNote
                        |> Maybe.withDefault False
            in
            ( model
            , if playedTheWantedNote then
                generateRandomPosition

              else
                Cmd.none
            )


port startListeningForFrequencyChanges : () -> Cmd msg


port stopListeningForFrequencyChanges : () -> Cmd msg


port onFrequencyChange : (Maybe Float -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.listening then
        onFrequencyChange GotFrequencyChange

    else
        Sub.none


view : Model -> Html Msg
view model =
    Element.layout [] <|
        column [ centerY, centerX, spacing 50 ] <|
            [ el [ centerX, Font.size 100 ] <|
                (model.position
                    |> Maybe.map viewPosition
                    |> Maybe.withDefault (text "")
                )
            , Input.button
                [ centerX
                , Border.rounded 9999
                , Element.paddingXY 40 20
                , Background.color grey
                , Font.size 30
                ]
              <|
                if model.listening then
                    { label = text "Stop practicing", onPress = Just Stop }

                else
                    { label = text "Start practicing", onPress = Just Start }
            ]


viewPosition : ( GuitarString, Note ) -> Element Msg
viewPosition ( guitarString, note ) =
    paragraph []
        [ el [ Font.bold ] (Note.view note)
        , el [ Font.light, Font.color grey ] (text " on the ")
        , el [ Font.bold ] (GuitarString.view guitarString)
        , el [ Font.light, Font.color grey ] (text " string")
        ]


grey : Color
grey =
    rgb 0.8 0.8 0.8
