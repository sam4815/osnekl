open! Base

type t = Left | Up | Right | Down [@@deriving sexp_of]

let next_position t { Position.row; col } : Position.t =
  match t with
  | Left -> { row; col = col - 1 }
  | Right -> { row; col = col + 1 }
  | Down -> { col; row = row - 1 }
  | Up -> { col; row = row + 1 }
