open Str
open Syntax

exception EvalError of string

type evalue =
  | VProduce of expr
  | VLambda of var * vtype * expr

let rec prettyR (r : evalue) : string =
  match r with
  | VProduce e -> ("produce " ^ Pretty.prettyE e)
  | VLambda (x, t, m) -> ("λ(" ^ x ^ ")\n" ^ Pretty.prettyE m)

let replace input output =
    Str.global_replace (Str.regexp_string input) output

let rec subst (e : expr) (x : var) (e' : value) : expr =
  match e with
  | EVar y ->
      if x = y then e'
      else EVar y
  | ENum n -> ENum n
  | EPrint (s, m) ->
      EPrint (replace ("$" ^ x) (Pretty.prettyE e') s, subst m x e')
  | EPlus (a, b) ->
      EPlus (subst a x e', subst b x e')
  | EMinus (a, b) ->
      EMinus (subst a x e', subst b x e')
  | ETimes (a, b) ->
      ETimes (subst a x e', subst b x e')
  | EProduce v ->
      EProduce (subst v x e')
  | EThunk m ->
      EThunk (subst m x e')
  | EForce v ->
      EForce (subst v x e')
  | ELet (y, v, m) ->
      ELet (y, subst v x e', substIfNE m x y e')
  | EEagerLet (m, y, n) ->
      EEagerLet (subst m x e', y, substIfNE n x y e')
  | EPush (v, m) ->
      EPush (subst v x e', subst m x e')
  | ELambda (y, a, m) ->
      ELambda (y, a, substIfNE m x y e')

and substIfNE e x y e' =
  if x = y then e else subst e x e'

let asEThunk (e : expr) =
  match e with
  | EThunk m -> m
  | _ -> raise (EvalError ("NotEThunk"))

let asVProduce (v : evalue) : expr =
  match v with
  | VProduce v -> v
  |  _ -> raise (EvalError ("NotVProduce"))

let asVLambda (v : evalue) =
  match v with
  | VLambda (x, t, m) -> (x, t, m)
  |  _ -> raise (EvalError ("NotVLambda"))

let rec eval (e : expr) : evalue =
  match e with
  | EVar _ -> raise (EvalError ("UnboundVariable"))
  | ENum _ -> raise (EvalError ("NotComputation"))
  | EPrint (s, m) ->
     evalPrint s;
     eval m
  | EPlus _ -> raise (EvalError ("NotComputation"))
  | EMinus _ -> raise (EvalError ("NotComputation"))
  | ETimes _ -> raise (EvalError ("NotComputation"))
  | EProduce v -> VProduce (evalArith v)
  | EThunk _ -> raise (EvalError ("NotComputation"))
  | EForce v ->
      let m = asEThunk v in
        eval m
  | ELet (x, v, m) ->  (* let x be V in M *)
     eval (subst m x v)
  | EEagerLet (m, x, n) ->  (* M to x in N *)
      let v = asVProduce (eval m) in
      eval (subst n x v)
  | EPush (v, m) ->
      let (x, t, n) = asVLambda (eval m) in
      eval (subst n x v)
  | ELambda (x, a, m) ->  (* λ(x:vtype) M *)
      VLambda (x, a, m)

and evalPrint (s : string) =
  print_string (s ^ "\n")

and evalArith (v : expr) : expr =
  match v with
  | ENum n -> ENum n
  | EPlus (e1, e2) ->
      let n1 = asInt (evalArith e1) in
      let n2 = asInt (evalArith e2) in
      ENum (n1 + n2)
  | EMinus (e1, e2) ->
      let n1 = asInt (evalArith e1) in
      let n2 = asInt (evalArith e2) in
      ENum (n1 - n2)
  | ETimes (e1, e2) ->
      let n1 = asInt (evalArith e1) in
      let n2 = asInt (evalArith e2) in
      ENum (n1 * n2)
  | EThunk m -> EThunk m
  | _ -> raise (EvalError ("NotArithExpr"))

and asInt (v : expr) : int =
  match v with
  | ENum n -> n
  | _ -> raise (EvalError ("NotNum"))