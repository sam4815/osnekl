open Lwt.Infix
open Notty
open Osnekl
module Term = Notty_lwt.Term

let counter = ref 0

let game =
  Game.create ~height:50 ~width:50 ~initial_snake_length:3 ~amount_to_grow:3

let grid xxs = xxs |> List.map I.hcat |> I.vcat

let outline attr t =
  let w, h = Term.size t in
  let chr x = I.uchar attr x 1 1
  and hbar = I.uchar attr (Uchar.of_int 0x2500) (w - 2) 1
  and vbar = I.uchar attr (Uchar.of_int 0x2502) 1 (h - 2) in
  let a, b, c, d =
    ( chr (Uchar.of_int 0x256d),
      chr (Uchar.of_int 0x256e),
      chr (Uchar.of_int 0x256f),
      chr (Uchar.of_int 0x2570) )
  in
  grid [ [ a; hbar; b ]; [ vbar; I.void (w - 2) 1; vbar ]; [ d; hbar; c ] ]

let rec increase_counter () =
  Lwt_unix.sleep 0.1 >>= fun () ->
  if !counter < max_int then counter := !counter + 1 else counter := 0;
  Lwt.return () >>= fun () -> increase_counter ()

let draw_block { Position.row; col } =
  let dot : image = I.uchar A.(fg lightgreen) (Uchar.of_int 0x25cf) 1 1 in
  I.pad ~t:(row + 2) ~l:(col + 2) dot

let draw_snake =
  let snake = Game.snake game in
  draw_block (Snake.head_location snake)
(* Snake head is a different color *)
(* draw_block ~color:Colors.head_color (List.hd_exn snake_locations) *)

let draw_game _ =
  (* let draw_block col row = *)
  let dot : image = I.uchar A.(fg lightred) (Uchar.of_int 0x25cf) 10 10 in
  let double_dot : image =
    I.uchar A.(fg lightgreen) (Uchar.of_int 0x25cf) 20 20
  in
  let wut =
    if !counter < 5 then I.pad ~t:10 ~l:10 double_dot else I.pad ~t:10 ~l:10 dot
  in
  I.(draw_snake </> wut)

let render term (w, h) =
  I.(outline A.(fg lightred) term </> draw_game { Position.col = w; row = h })

let timer () = Lwt_unix.sleep 0.1 >|= fun () -> `Timer

let event term =
  Lwt_stream.get (Term.events term) >|= function
  | Some ((`Resize _ | #Unescape.event) as x) -> x
  | None -> `End

let rec loop term (e, t) dim =
  e <?> t >>= function
  | `End | `Key (`Escape, []) -> Lwt.return_unit
  | `Key (`Arrow `Up, []) ->
      counter := 0;
      loop term (event term, t) dim
  | `Timer ->
      Term.image term (render term dim) >>= fun () ->
      loop term (e, timer ()) dim
  | `Mouse ((`Press _ | `Drag), (_, _), _) -> loop term (event term, t) dim
  | `Resize dim ->
      Term.image term (render term dim) >>= fun () ->
      loop term (event term, t) dim
  | _ -> loop term (event term, t) dim

let interface () =
  let tc = Unix.(tcgetattr stdin) in
  Unix.(tcsetattr stdin TCSANOW { tc with c_isig = false });
  let term = Term.create () in
  let size = Term.size term in
  loop term (event term, timer ()) size

let main () = Lwt.choose [ increase_counter (); interface () ]
let () = Lwt_main.run (main ())
