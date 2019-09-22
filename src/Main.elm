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


type GuitarString
    = First
    | Second
    | Third
    | Fourth
    | Fifth
    | Sixth


init : () -> ( Model, Cmd Msg )
init _ =
    ( { position = Nothing, speed = 1, listening = False }
    , Cmd.none
    )


generateRandomPosition : Cmd Msg
generateRandomPosition =
    Random.pair
        (Random.uniform First [ Second, Third, Fourth, Fifth, Sixth ])
        Note.generator
        |> Random.generate GotRandomPosition


type Msg
    = GotRandomPosition ( GuitarString, Note )
    | GotFrequencyChange (Maybe Float)
    | StartListeningForFrequencyChanges


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotRandomPosition position ->
            ( { model | position = Just position }, Cmd.none )

        StartListeningForFrequencyChanges ->
            ( { model | listening = True }
            , if not model.listening then
                Cmd.batch
                    [ startListeningForFrequencyChanges ()
                    , generateRandomPosition
                    ]

              else
                Cmd.none
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
                , Element.paddingXY 20 10
                , Background.color grey
                ]
                { label = text "Start practicing"
                , onPress = Just StartListeningForFrequencyChanges
                }
            ]


viewPosition : ( GuitarString, Note ) -> Element Msg
viewPosition ( guitarString, note ) =
    paragraph []
        [ el [ Font.bold ] (Note.view note)
        , el [ Font.light, Font.color grey ] (text " on the ")
        , el [ Font.bold ] (text (Debug.toString guitarString))
        , el [ Font.light, Font.color grey ] (text " string")
        ]


grey : Color
grey =
    rgb 0.8 0.8 0.8
