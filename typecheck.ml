open Syntax

type env = (var * vtype) list

exception TypeCheckError of string

let asThunk (t : gtype) =
  match t with
  | TVThunk t -> t
  | _ -> raise (TypeCheckError ("NotTVThunk"))

let asPair (t : gtype) =
  match t with
  | TVPair (t, t') -> (t, t')
  | _ -> raise (TypeCheckError ("NotTVPair"))

let asProduce (t : gtype) =
  match t with
  | TCProduce t -> t
  | _ -> raise (TypeCheckError ("NotTCProduce"))

let asArrDomain (t : gtype) =
  match t with
  | TCArr (a,b) -> a
  | _ -> raise (TypeCheckError ("NotTCArr"))

let asArrRange (t : gtype) =
  match t with
  | TCArr (a,b) -> b
  | _ -> raise (TypeCheckError ("NotTCArr"))

let rec infer (env : env) (e : expr) : gtype =
  match e with
  | EVar x ->
      (try
         List.assoc x env
       with
         Not_found -> raise (TypeCheckError ("UnknownVariable: " ^ x)))
  | ENum _ -> TVNum
  | EString _ -> TVString
  | EPrint (_, m) ->
      let t = infer env m in
        checkCType t ;
        t
  | EPlus (e1, e2) ->
      check env e1 TVNum ;
      check env e2 TVNum ;
      TVNum
  | EMinus (e1, e2) ->
      check env e1 TVNum ;
      check env e2 TVNum ;
      TVNum
  | ETimes (e1, e2) ->
      check env e1 TVNum ;
      check env e2 TVNum ;
      TVNum
  | EUnit -> TVUnit
  | EPair (e1, e2) ->
      let t = infer env e1 in
      let t' = infer env e2 in
        checkVType t ;
	checkVType t';
	TVPair (t, t')
  | EPMPair (e, (x, y), m) ->
      let (t, t') = asPair (infer env e) in
        checkVType t ;
	checkVType t';
	infer ((x,t) :: (y,t') :: env) m
  | EProduce v ->
      let t = infer env v in
        checkVType t ;
        TCProduce t
  | EThunk m ->
      let t = infer env m in
        checkCType t ;
        TVThunk t
  | EForce v ->
      let t = asThunk (infer env v) in
        checkCType t ;
        t
  | ELet (x, v, m) ->  (* let x be v in m *)
      let t = infer env v in
        checkVType t ;
        let tm = infer ((x,t) :: env) m in
          checkCType tm ;
          tm
  | EEagerLet (m, x, n) ->  (* M to x in N *)
      let tm = asProduce (infer env m) in
        checkVType tm;
        infer ((x,tm) :: env) n
  | EPush (v, m) ->  (* V'M *)
      let a = infer env v in
      let ab = infer env m in (* A -> B *)
        checkVType a ;
        checkVType (asArrDomain ab) ;
        checkCType (asArrRange ab) ;
        checkTypesEq a (asArrDomain ab) ;
        asArrRange ab
  | ELambda (x, a, m) ->  (* λ(x:vtype) M *)
      let b = infer ((x, a) :: env) m in
        checkVType a ;
        checkCType b ;
        TCArr (a, b)

and check (env : env) (e : expr) (t : gtype) =
  let t' = infer env e
  in if not (t = t') then raise (TypeCheckError ("TypeMismatch: " ^ Pretty.prettyT t ^ " != " ^ Pretty.prettyT t'))

and checkTypesEq (t : gtype) (t' : gtype) =
  if not (t = t') then raise (TypeCheckError ("TypeMismatch: " ^ Pretty.prettyT t ^ " != " ^ Pretty.prettyT t'))

and checkVType (t : gtype) =
  match t with
  | TVNum -> ()
  | TVString -> ()
  | TVUnit -> ()
  | TVPair (t1, t2) ->
      checkVType t1 ;
      checkVType t2
  | TVThunk t -> checkCType t
  | ( TCProduce _ | TCArr _ ) -> raise (TypeCheckError ("NotValue: " ^ Pretty.prettyT t ))

and checkCType (t : gtype) =
  match t with
  | (TVNum | TVThunk _ | TVUnit | TVPair _ | TVString ) -> raise (TypeCheckError ("NotComputation: " ^ Pretty.prettyT t ))
  | TCProduce t -> checkVType t
  | TCArr (t, t') ->
      checkVType t ;
      checkCType t'
