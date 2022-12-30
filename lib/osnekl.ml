open! Notty
open! Notty_unix

let () = I.string A.(fg lightred) "Wow!" |> eol |> Notty_unix.output_image
