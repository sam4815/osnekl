open! Base

type t = Left | Up | Right | Down [@@deriving sexp_of]

val next_position : t -> Position.t -> Position.t
