open Syntax

let rec prettyT (t : gtype) : string =
  match t with
  | TVNum -> "Num"
  | TVString -> "Str"
  | TVThunk t -> ("U (" ^ (prettyT t) ^ ")")
  | TVUnit -> "Unit"
  | TVPair (t, t') -> (prettyT t ^ " × " ^ prettyT t')
  | TCProduce t -> ("F (" ^ (prettyT t) ^ ")")
  | TCArr (t, t') -> ((prettyT t) ^ " -> " ^ (prettyT t'))

let rec prettyE (e : expr) : string =
  match e with
  | EVar x -> x
  | ENum n -> string_of_int n
  | EString s -> s
  | EPrint (s, m)-> ("print \"" ^ s ^ "\";\n" ^ prettyE m)
  | EPlus (a, b) -> (prettyE a ^ "+" ^ prettyE b)
  | EMinus (a, b) -> (prettyE a ^ "-" ^ prettyE b)
  | ETimes (a, b) -> (prettyE a ^ "*" ^ prettyE b)
  | EIfz (e, m, x, m') -> ("ifz (" ^ prettyE e ^ ") then\n" ^ prettyE m ^ "\nelse " ^ x ^ " .\n" ^ prettyE m' ^ "\nzfi")
  | EUnit -> "()"
  | EPair (a, b) -> ("(" ^ prettyE a ^ ", " ^ prettyE b ^ ")")
  | EPMPair (e, (x, y), m) -> ("pm " ^ prettyE e ^ " as (" ^ x ^ ", " ^ y ^ ") in " ^ prettyE m)
  | EProduce v -> ("produce (" ^ prettyE v ^ ")")
  | EThunk m -> ("thunk (" ^ prettyE m ^ ")\n")
  | EForce v -> ("force (" ^ prettyE v ^ ")\n")
  | ELet (x, v, m) -> ("let " ^ x ^ " be " ^ prettyE v ^ " in\n" ^ prettyE m)
  | EEagerLet (m, x, n) -> ("(" ^ prettyE m ^ ") to " ^ x ^ " in\n" ^ prettyE n)
  | EPush (v, m) -> (prettyE v ^ "'\n" ^ prettyE m)
  | ELambda (x, t, m) -> ("λ(" ^ x ^ ")\n" ^ prettyE m)
  | EFix (t, x, m) -> ("fix {" ^ prettyT t ^ "} (" ^ x ^ " . " ^ prettyE m)
  | EWait m -> ("wait;" ^ prettyE m)
