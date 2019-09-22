module Note exposing (Note, fromFrequency, generator, view)

import Array exposing (Array)
import Element exposing (Element)
import Random


type Note
    = C
    | CSharp
    | D
    | DSharp
    | E
    | F
    | FSharp
    | G
    | GSharp
    | A
    | ASharp
    | B


list : Array Note
list =
    Array.fromList
        [ C
        , CSharp
        , D
        , DSharp
        , E
        , F
        , FSharp
        , G
        , GSharp
        , A
        , ASharp
        , B
        ]


generator : Random.Generator Note
generator =
    Random.uniform C [ CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B ]


fromFrequency : Float -> Maybe Note
fromFrequency frequency =
    let
        a4 =
            440

        semitones =
            69

        n =
            modBy 12 (round (12 * (logBase e (frequency / a4) / logBase e 2)) + semitones)
    in
    Array.get n list


view : Note -> Element msg
view note =
    Element.text <|
        case note of
            C ->
                "C"

            CSharp ->
                "C♯"

            D ->
                "D"

            DSharp ->
                "D♯"

            E ->
                "E"

            F ->
                "F"

            FSharp ->
                "F♯"

            G ->
                "G"

            GSharp ->
                "G♯"

            A ->
                "A"

            ASharp ->
                "A♯"

            B ->
                "B"
