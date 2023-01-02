open Lwt.Infix
open Notty
open Osnekl
module Term = Notty_lwt.Term

let game =
  ref
    (Game.create ~height:10 ~width:10 ~initial_snake_length:3 ~amount_to_grow:3)

let rec step_game () =
  Lwt_unix.sleep 0.1 >>= fun () ->
  Game.step !game;
  Lwt.return () >>= fun () -> step_game ()

let grid xxs = xxs |> List.map I.hcat |> I.vcat

let outline () =
  let w, h = ((Game.width !game * 2) + 2, Game.height !game + 2) in
  let chr x = I.uchar A.(fg lightred) x 1 1
  and hbar = I.uchar A.(fg lightred) (Uchar.of_int 0x2500) (w - 2) 1
  and vbar = I.uchar A.(fg lightred) (Uchar.of_int 0x2502) 1 (h - 2) in
  let a, b, c, d =
    ( chr (Uchar.of_int 0x256d),
      chr (Uchar.of_int 0x256e),
      chr (Uchar.of_int 0x256f),
      chr (Uchar.of_int 0x2570) )
  in
  grid [ [ a; hbar; b ]; [ vbar; I.void (w - 2) 1; vbar ]; [ d; hbar; c ] ]

let draw_block (_, h) { Position.row; col } (color : A.color) =
  let dot : image = I.uchar A.(fg color) (Uchar.of_int 0x25cf) 1 1 in
  I.pad ~t:(h - row - 2) ~l:((col * 2) + 1) dot

let draw_snake (w, h) snake =
  let snake_locations : Position.t list = Snake.locations snake in
  let locations =
    List.map (fun pos -> draw_block (w, h) pos A.green) snake_locations
  in
  List.fold_left
    (fun a b -> I.(a </> b))
    (draw_block (w, h) (Snake.head_location snake) A.yellow)
    locations

let draw_apple (w, h) apple = draw_block (w, h) (Apple.location apple) A.red

let draw_game (w, h) =
  let apple = draw_apple (w, h) (Game.apple !game) in
  let snake = draw_snake (w, h) (Game.snake !game) in
  I.(snake </> apple)

let render (w, h) = I.(outline () </> draw_game (w, h))
let timer () = Lwt_unix.sleep 0.1 >|= fun () -> `Timer

let event term =
  Lwt_stream.get (Term.events term) >|= function
  | Some ((`Resize _ | #Unescape.event) as x) -> x
  | None -> `End

let rec loop term (e, t) dim =
  e <?> t >>= function
  | `End | `Key (`Escape, []) -> Lwt.return_unit
  | `Key (`Arrow `Up, []) | `Key (`ASCII 'w', _) ->
      Game.set_direction !game Up;
      loop term (event term, t) dim
  | `Key (`Arrow `Down, []) | `Key (`ASCII 's', _) ->
      Game.set_direction !game Down;
      loop term (event term, t) dim
  | `Key (`Arrow `Left, []) | `Key (`ASCII 'a', _) ->
      Game.set_direction !game Left;
      loop term (event term, t) dim
  | `Key (`Arrow `Right, []) | `Key (`ASCII 'd', _) ->
      Game.set_direction !game Right;
      loop term (event term, t) dim
  | `Key (`Enter, []) | `Key (`ASCII ' ', _) ->
      Game.step !game;
      loop term (event term, t) dim
  | `Key (`ASCII 'r', _) ->
      game :=
        Game.create ~height:(Game.height !game) ~width:(Game.width !game)
          ~initial_snake_length:3 ~amount_to_grow:3;
      loop term (event term, t) dim
  | `Timer ->
      Term.image term (render dim) >>= fun () -> loop term (e, timer ()) dim
  | `Mouse ((`Press _ | `Drag), (_, _), _) -> loop term (event term, t) dim
  | `Resize dim ->
      Term.image term (render dim) >>= fun () -> loop term (event term, t) dim
  | _ -> loop term (event term, t) dim

let interface () =
  let tc = Unix.(tcgetattr stdin) in
  Unix.(tcsetattr stdin TCSANOW { tc with c_isig = false });
  let term = Term.create () in
  let w, h = Term.size term in
  game :=
    Game.create ~height:(h - 2)
      ~width:((w - 1) / 2)
      ~initial_snake_length:3 ~amount_to_grow:3;
  loop term (event term, timer ()) (w, h)

let main () = Lwt.choose [ step_game (); interface () ]
let () = Lwt_main.run (main ())
