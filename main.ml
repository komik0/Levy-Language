open Parsing
open Typecheck
open Pretty

let parse lexbuf =
  try Parser.prog Lexer.read lexbuf
  with Parser.Error -> failwith "Syntax error"

let main fname =
  let inx = open_in fname in
  let lexbuf = Lexing.from_channel inx in
  lexbuf.Lexing.lex_curr_p <- { lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = fname };
  let e = parse lexbuf in
  close_in inx;
  let t = infer [] e in
  Printf.printf "=== TypeCheck  ===\n";
  Printf.printf "%s --: %s\n" (Pretty.prettyE e) (Pretty.prettyT t);
  Printf.printf "=== Evaluation ===\n";
  let result = Eval.eval e in
  Printf.printf "===  ProgRes   ===\n";
    Printf.printf "%s\n" (Eval.prettyR result)

let () =
  let n = Array.length Sys.argv in
  match n with
  | 2 -> main Sys.argv.(1)
  | _ -> Printf.printf "Usage: main filaname.\n"; exit 1
