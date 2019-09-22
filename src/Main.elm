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
import Random
import Time


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { position = Nothing, speed = 1, listening = False }
    , generateRandomPosition
    )


type alias Model =
    { position :
        Maybe ( GuitarString, Note )
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


type Note
    = C
    | D
    | E
    | F
    | G
    | A
    | B


generateRandomPosition : Cmd Msg
generateRandomPosition =
    Random.pair
        (Random.uniform First [ Second, Third, Fourth, Fifth, Sixth ])
        (Random.uniform C [ D, E, F, G, A, B ])
        |> Random.generate GotRandomPosition


type Msg
    = GotRandomPosition ( GuitarString, Note )
    | GenerateRandomPosition
    | AdjustSpeed Float
    | GotFrequencyChange (Maybe Float)
    | StartListeningForFrequencyChanges


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateRandomPosition ->
            ( model, generateRandomPosition )

        GotRandomPosition position ->
            ( { model | position = Just position }, Cmd.none )

        AdjustSpeed speed ->
            ( { model | speed = round speed }, Cmd.none )

        StartListeningForFrequencyChanges ->
            ( { model | listening = True }
            , if not model.listening then
                startListeningForFrequencyChanges ()

              else
                Cmd.none
            )

        GotFrequencyChange frequency ->
            let
                _ =
                    Debug.log "frequency" frequency
            in
            ( model, Cmd.none )


port startListeningForFrequencyChanges : () -> Cmd msg


port onFrequencyChange : (Maybe Float -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every (toFloat model.speed * 1000) (always GenerateRandomPosition)
        , if model.listening then
            onFrequencyChange GotFrequencyChange

          else
            Sub.none
        ]


view : Model -> Html Msg
view model =
    Element.layout [] <|
        column [ centerY, centerX, spacing 50 ] <|
            [ el [ centerX, Font.size 100 ] <|
                (model.position
                    |> Maybe.map viewPosition
                    |> Maybe.withDefault (text "")
                )
            , viewSpeed model.speed
            , Input.button [] { label = text "lyssna", onPress = Just StartListeningForFrequencyChanges }
            ]


viewPosition : ( GuitarString, Note ) -> Element Msg
viewPosition ( guitarString, note ) =
    paragraph []
        [ el [ Font.bold ] (text (Debug.toString note))
        , el [ Font.light, Font.color grey ] (text " on the ")
        , el [ Font.bold ] (text (Debug.toString guitarString))
        , el [ Font.light, Font.color grey ] (text " string")
        ]


viewSpeed : Int -> Element Msg
viewSpeed speed =
    el
        [ Element.height (Element.px 30)
        , Element.width (Element.px 500)
        , centerX
        ]
    <|
        Input.slider
            [ Element.height (Element.px 30)
            , Element.width (Element.px 500)
            , centerX
            , Element.behindContent
                (Element.el
                    [ Element.width Element.fill
                    , Element.height (Element.px 2)
                    , Element.centerY
                    , Background.color grey
                    , Border.rounded 2
                    ]
                    Element.none
                )
            ]
            { onChange = AdjustSpeed
            , label =
                Input.labelBelow [ centerX ] <|
                    paragraph [ Font.size 14 ] <|
                        [ el [ Font.color grey ] (text "New position ") ]
                            ++ speedToWord speed
                            ++ [ el [ Font.color grey ] (text " second")
                               ]
            , min = 1
            , max = 10
            , step = Just 1
            , value = toFloat speed
            , thumb =
                Input.defaultThumb
            }


speedToWord : Int -> List (Element Msg)
speedToWord speed =
    let
        s =
            case speed of
                1 ->
                    ""

                2 ->
                    "2nd"

                3 ->
                    "3rd"

                n ->
                    String.fromInt n
                        ++ "th"
    in
    if String.isEmpty s then
        [ text "every" ]

    else
        [ el [ Font.color grey ] (text "every "), text s ]


grey : Color
grey =
    rgb 0.8 0.8 0.8
