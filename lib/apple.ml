open! Base

type t = { location : Position.t } [@@deriving sexp_of]

let location t = t.location

let create ~height ~width ~invalid_locations =
  let valid_locations =
    List.init height ~f:(fun row ->
        List.init width ~f:(fun col -> { Position.row; col }))
    |> List.concat
    |> List.filter ~f:(fun pos ->
           not
             (List.exists invalid_locations ~f:(fun location ->
                  [%compare.equal: Position.t] location pos)))
  in
  match List.length valid_locations with
  | 0 -> None
  | _ -> Some { location = List.random_element_exn valid_locations }
