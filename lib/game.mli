open! Base

type t [@@deriving sexp_of]

val create :
  height:int -> width:int -> initial_snake_length:int -> amount_to_grow:int -> t

val snake : t -> Snake.t
val set_direction : t -> Direction.t -> unit
val apple : t -> Apple.t
val game_state : t -> Game_state.t
val step : t -> unit
val in_bounds : t -> Position.t -> bool

module For_testing : sig
  val create_game_with_apple_exn :
    height:int ->
    width:int ->
    initial_snake_length:int ->
    amount_to_grow:int ->
    apple_location:Position.t ->
    t

  val create_apple_and_update_game_exn : t -> apple_location:Position.t -> unit
end
