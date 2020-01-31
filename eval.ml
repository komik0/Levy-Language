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
  | EString s ->
      EString (replace ("$" ^ x) (Pretty.prettyE e') s)
  | EPrint (s, m) ->
      EPrint (replace ("$" ^ x) (Pretty.prettyE e') s, subst m x e')
  | EPlus (a, b) ->
      EPlus (subst a x e', subst b x e')
  | EMinus (a, b) ->
      EMinus (subst a x e', subst b x e')
  | ETimes (a, b) ->
      ETimes (subst a x e', subst b x e')
  | EIfz (e, m, y, m') ->
      EIfz (subst e x e', subst m x e', y, substIfNE m' x y e')
  | EUnit -> EUnit
  | EPair (e1, e2) -> EPair (subst e1 x e', subst e2 x e')
  | EPMPair (e, (x', y), m) ->
      if x = x' || x = y then EPMPair (subst e x e', (x', y), m)
      else EPMPair (subst e x e', (x', y), subst m x e')
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
  | EFix (t, x', m) ->
      EFix (t, x', substIfNE m x x' e')
  | EWait m ->
      EWait (subst m x e')

and substIfNE e x y e' =
  if x = y then e else subst e x e'

let asEThunk (e : expr) =
  match e with
  | EThunk m -> m
  | _ -> raise (EvalError ("NotEThunk"))

let asEPair (e : expr) =
  match e with
  | EPair (e1, e2) -> (e1, e2)
  | _ -> raise (EvalError ("NotEPair"))

let asVProduce (v : evalue) : expr =
  match v with
  | VProduce v -> v
  |  _ -> raise (EvalError ("NotVProduce"))

let asVLambda (v : evalue) =
  match v with
  | VLambda (x, t, m) -> (x, t, m)
  |  _ -> raise (EvalError ("NotVLambda"))

let asInt (v : expr) : int =
  match v with
  | ENum n -> n
  | _ -> raise (EvalError ("NotNum"))

let rec eval (e : expr) : evalue =
  match e with
  | EVar _ -> raise (EvalError ("UnboundVariable"))
  | ENum _ -> raise (EvalError ("NotComputation"))
  | EString _ -> raise (EvalError ("NotComputation"))
  | EPrint (s, m) ->
     evalPrint s;
     eval m
  | EPlus _ -> raise (EvalError ("NotComputation"))
  | EMinus _ -> raise (EvalError ("NotComputation"))
  | ETimes _ -> raise (EvalError ("NotComputation"))
  | EIfz (e, m, x, m') ->
      let v = evalArith e in
        if v = (ENum 0) then eval m
        else eval (subst m' x v)
  | EUnit -> raise (EvalError ("NotComputation"))
  | EPair _ -> raise (EvalError ("NotComputation"))
  | EPMPair (e, (x, y), m) ->
      let (e1, e2) = asEPair e in
        eval (subst (subst m x e1) y e2)
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
      eval (subst n x (evalArith v))
  | ELambda (x, a, m) ->  (* λ(x:vtype) M *)
      VLambda (x, a, m)
  | EFix (t, x, m) ->
      eval (subst m x (EThunk (EFix (t, x, m))))
  | EWait m ->
      let _ = read_line () in
        eval m


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
  | EUnit -> EUnit
  | EPair (x, y) -> EPair (evalArith x, evalArith y)
  | _ -> raise (EvalError ("NotArithExpr"))
