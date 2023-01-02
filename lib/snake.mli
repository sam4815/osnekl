open! Base

type t [@@deriving sexp_of]

val create : length:int -> t
val grow_over_next_steps : t -> int -> t
val locations : t -> Position.t list
val head_location : t -> Position.t
val set_direction : t -> Direction.t -> t
val step : t -> t option
