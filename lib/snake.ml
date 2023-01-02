open! Base

type t = {
  direction : Direction.t;
  extensions_remaining : int;
  locations : Position.t list;
}
[@@deriving sexp_of]

let create ~length =
  let locations =
    List.init length ~f:(fun col ->
        { Position.row = 0; col = length - 1 - col })
  in
  { direction = Right; extensions_remaining = 0; locations }

let grow_over_next_steps t by_how_much =
  { t with extensions_remaining = t.extensions_remaining + by_how_much }

let locations t = t.locations

let head_location t =
  match t.locations with hd :: tl -> hd | [] -> { Position.row = 0; col = 0 }

let set_direction t direction = { t with direction }

let rec has_duplicate_position lst =
  match lst with
  | [] -> false
  | hd :: tl ->
      List.exists tl ~f:(fun location ->
          [%compare.equal: Position.t] location hd)
      || has_duplicate_position tl

let step t =
  let locations =
    match t.extensions_remaining with
    | 0 ->
        Direction.next_position t.direction (head_location t)
        :: List.filteri t.locations ~f:(fun i pos ->
               i <> List.length t.locations - 1)
    | _ -> Direction.next_position t.direction (head_location t) :: t.locations
  in
  match (has_duplicate_position locations, t.extensions_remaining) with
  | true, _ -> None
  | false, 0 -> Some { t with locations }
  | false, _ ->
      Some
        { t with locations; extensions_remaining = t.extensions_remaining - 1 }
