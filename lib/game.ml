open! Base

type t = {
  mutable snake : Snake.t;
  mutable apple : Apple.t;
  mutable game_state : Game_state.t;
  height : int;
  width : int;
  amount_to_grow : int;
}
[@@deriving sexp_of]

let in_bounds t { Position.row; col } =
  col < t.width && row < t.height && col >= 0 && row >= 0

let create ~height ~width ~initial_snake_length ~amount_to_grow =
  let snake = Snake.create ~length:initial_snake_length in
  let apple =
    match
      Apple.create ~height ~width ~invalid_locations:(Snake.locations snake)
    with
    | None -> failwith "unable to create initial apple"
    | Some apple -> apple
  in
  let game =
    { height; width; snake; apple; amount_to_grow; game_state = In_progress }
  in
  match
    List.exists (Snake.locations snake) ~f:(fun position ->
        not (in_bounds game position))
  with
  | true -> failwith "unable to create initial snake"
  | false -> game

let width t = t.width
let height t = t.height
let snake t = t.snake
let apple t = t.apple
let game_state t = t.game_state
let set_direction t direction = t.snake <- Snake.set_direction t.snake direction

let step t =
  match game_state t with
  | Win | Game_over _ -> ()
  | In_progress -> (
      let snake = Snake.step t.snake in
      match snake with
      | None -> t.game_state <- Game_over "Self collision"
      | Some snake -> (
          if not (in_bounds t (Snake.head_location snake)) then
            t.game_state <- Game_over "Wall collision"
          else t.snake <- snake;
          if
            [%compare.equal: Position.t] (Apple.location t.apple)
              (Snake.head_location t.snake)
          then
            match
              Apple.create ~height:t.height ~width:t.width
                ~invalid_locations:(Snake.locations snake)
            with
            | None -> t.game_state <- Win
            | Some apple ->
                t.apple <- apple;
                t.snake <- Snake.grow_over_next_steps snake t.amount_to_grow))

module For_testing = struct
  let create_apple_force_location_exn ~height ~width ~location =
    let invalid_locations =
      List.init height ~f:(fun row ->
          List.init width ~f:(fun col -> { Position.row; col }))
      |> List.concat
      |> List.filter ~f:(fun pos ->
             not ([%compare.equal: Position.t] location pos))
    in
    match Apple.create ~height ~width ~invalid_locations with
    | None ->
        failwith "[Apple.create] returned [None] when [Some _] was expected!"
    | Some apple -> apple

  let create_apple_and_update_game_exn t ~apple_location =
    let apple =
      create_apple_force_location_exn ~height:t.height ~width:t.width
        ~location:apple_location
    in
    t.apple <- apple

  let create_game_with_apple_exn ~height ~width ~initial_snake_length
      ~amount_to_grow ~apple_location =
    let t = create ~height ~width ~initial_snake_length ~amount_to_grow in
    create_apple_and_update_game_exn t ~apple_location;
    t
end
