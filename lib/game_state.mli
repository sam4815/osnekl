open! Base

type t = In_progress | Game_over of string | Win [@@deriving sexp_of]

val to_string : t -> string
