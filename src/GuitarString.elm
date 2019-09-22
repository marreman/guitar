module GuitarString exposing (GuitarString, generator, view)

import Element exposing (Element)
import Random


type GuitarString
    = First
    | Second
    | Third
    | Fourth
    | Fifth
    | Sixth


generator : Random.Generator GuitarString
generator =
    Random.uniform First [ Second, Third, Fourth, Fifth, Sixth ]


view : GuitarString -> Element msg
view guitarString =
    Element.text <|
        case guitarString of
            First ->
                "first"

            Second ->
                "second"

            Third ->
                "third"

            Fourth ->
                "fourth"

            Fifth ->
                "fifth"

            Sixth ->
                "sixth"
