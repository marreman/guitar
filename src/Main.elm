module Main exposing (main)

import Browser
import Element
    exposing
        ( Element
        , centerX
        , centerY
        , column
        , el
        , paddingXY
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


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Nothing
    , generateRandomPosition
    )


type alias Model =
    Maybe ( GuitarString, Note )


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


generateRandomPosition =
    Random.pair
        (Random.uniform First [ Second, Third, Fourth, Fifth, Sixth ])
        (Random.uniform C [ D, E, F, G, A, B ])
        |> Random.generate GotRandomPosition


type Msg
    = GotRandomPosition ( GuitarString, Note )
    | GenerateRandomPosition


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
        GenerateRandomPosition ->
            ( model, generateRandomPosition )

        GotRandomPosition position ->
            ( Just position, Cmd.none )


view : Model -> Html Msg
view model =
    Element.layout [] <|
        column [ centerY, centerX, spacing 50 ] <|
            [ el [ centerX, Font.size 100 ] <|
                (model
                    |> Maybe.map viewPosition
                    |> Maybe.withDefault (text "")
                )
            , Input.button
                [ centerX
                , Background.color (rgb 0 0 0)
                , Font.color (rgb 1 1 1)
                , Font.variant Font.smallCaps
                , paddingXY 25 15
                , Border.rounded 9999
                , Font.bold
                ]
                { label = text "generate random position"
                , onPress = Just GenerateRandomPosition
                }
            ]


viewPosition : ( GuitarString, Note ) -> Element Msg
viewPosition ( guitarString, note ) =
    paragraph []
        [ el [ Font.bold ] (text (Debug.toString note))
        , el [ Font.light, Font.color (rgb 0.8 0.8 0.8) ] (text " on the ")
        , el [ Font.bold ] (text (Debug.toString guitarString))
        , el [ Font.light, Font.color (rgb 0.8 0.8 0.8) ] (text " string")
        ]
