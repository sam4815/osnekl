open! Base

type t [@@deriving sexp_of]

val create :
  height:int -> width:int -> invalid_locations:Position.t list -> t option

val location : t -> Position.t
