open! Notty
open! Notty_unix

let rec main_loop t =
  let img = I.(string A.(bg lightred ++ fg black) "This is a great example") in
  Term.image t img;
  match Term.event t with `End | `Key (`Escape, []) -> () | _ -> main_loop t

let () =
  let t = Term.create () in
  main_loop t
