module Types.Session exposing
    ( Round
    , Session
    , SessionId
    , SessionStatus(..)
    , sessionStatusColor
    , sessionStatusToString
    )

import Time



-- TYPES


type alias SessionId =
    String


type alias Session =
    { id : SessionId
    , participantName : String
    , currentRound : Int
    , totalRounds : Int
    , startedAt : Time.Posix
    , lastActivity : Time.Posix
    , description : String
    , status : SessionStatus
    }


type SessionStatus
    = Waiting
    | Ready
    | Overdue


type alias Round =
    { roundNumber : Int
    , yourLetter : Maybe String
    , theirLetter : Maybe String
    , isRevealed : Bool
    , submittedAt : Maybe Time.Posix
    }



-- HELPERS


sessionStatusToString : SessionStatus -> String
sessionStatusToString status =
    case status of
        Waiting ->
            "Waiting"

        Ready ->
            "Ready"

        Overdue ->
            "Overdue"


sessionStatusColor : SessionStatus -> String
sessionStatusColor status =
    case status of
        Waiting ->
            "orange"

        Ready ->
            "blue"

        Overdue ->
            "red"
