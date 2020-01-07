open Syntax

let rec prettyT t =
  match t with
  | TVNum -> "Num"
  | TVThunk t -> ("U (" ^ (prettyT t) ^ ")")
  | TCProduce t -> ("F (" ^ (prettyT t) ^ ")")
  | TCArr (t, t') -> ((prettyT t) ^ " -> " ^ (prettyT t'))

let rec prettyE (e : expr) : string =
  match e with
  | EVar x -> x
  | ENum n -> string_of_int n
  | EPrint (s, m)-> ("print \"" ^ s ^ "\";\n" ^ prettyE m)
  | EPlus (a, b) -> (prettyE a ^ "+" ^ prettyE b)
  | EMinus (a, b) -> (prettyE a ^ "-" ^ prettyE b)
  | ETimes (a, b) -> (prettyE a ^ "*" ^ prettyE b)
  | EProduce v -> ("produce (" ^ prettyE v ^ ")\n")
  | EThunk m -> ("thunk (" ^ prettyE m ^ ")\n")
  | EForce v -> ("force (" ^ prettyE v ^ ")\n")
  | ELet (x, v, m) -> ("let " ^ x ^ " be " ^ prettyE v ^ " in\n" ^ prettyE m)
  | EEagerLet (m, x, n) -> ("(" ^ prettyE m ^ ") to " ^ x ^ " in\n" ^ prettyE n)
  | EPush (v, m) -> (prettyE v ^ "'\n" ^ prettyE m)
  | ELambda (x, t, m) -> ("λ(" ^ x ^ ")\n" ^ prettyE m)
