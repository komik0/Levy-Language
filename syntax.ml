type gtype =  (* generalized Levy's type *)
  | TVNum                   (* Number *)
  | TVThunk of ctype        (* U B *)
  | TCProduce of vtype      (* F A *)
  | TCArr of vtype * ctype  (* A -> B *)
and vtype = gtype
and ctype = gtype


type var = string
type value = expr
and expr =
  | EVar of var
  | ENum of int
  | EPrint of string * expr         (* print "x = $x" ; M *)
  | EPlus of value * value
  | EMinus of value * value
  | ETimes of value * value
  | EProduce of value               (* produce V *)
  | EThunk of expr                  (* thunk M *)
  | EForce of value                 (* force V *)
  | ELet of var * value * expr      (* let x be V in M *)
  | EEagerLet of expr * var * expr  (* M to x in N *)
  | EPush of value * expr           (* Push val into the stack - V'M *)
  | ELambda of var * vtype * expr   (* Pop value - λ(x:vtype) M *)
