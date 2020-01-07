%token <string> ID
%token <int> NUM
%token <string> STR
%token COL SCOL
%token LAM
%token PUSH
%token LET BE TO IN
%token PRODUCE
%token THUNK
%token FORCE
%token PRINT
%token PLUS MINUS TIMES
%token ARR
%token INT
%token LPAR RPAR
%token EOF

%right ARR
%left PLUS MINUS
%left TIMES

%start <Syntax.expr> prog

%%

prog:
  | e = expr; EOF {e}

expr:
  | e = arith {e}
  | PRINT; s = STR; SCOL; e = expr {Syntax.EPrint (s, e)}
  | PRODUCE; e = arith {Syntax.EProduce e}
  | THUNK; LPAR; e = expr; RPAR {Syntax.EThunk e}
  | FORCE; v = expr {Syntax.EForce(v)}
  | LET; x = ID; BE; e1 = expr; IN; e2 = expr {Syntax.ELet (x, e1, e2)}
  | m = expr; TO; w = ID; IN; n = expr {Syntax.EEagerLet (m, w, n)}
  | v = expr; PUSH; m = expr {Syntax.EPush (v, m)}
  | LAM; LPAR; x = ID; COL; t = typ; RPAR; e = expr  {Syntax.ELambda (x, t, e)}
  | LPAR; e = expr; RPAR {e}

arith:
  | n = NUM {Syntax.ENum n}
  | x = ID  {Syntax.EVar x}
  | a = arith; PLUS;  b = arith {Syntax.EPlus (a, b)}
  | a = arith; MINUS; b = arith {Syntax.EMinus (a, b)}
  | a = arith; TIMES; b = arith {Syntax.ETimes (a, b)}

typ:
  | t1 = typ; ARR;  t2 = typ {Syntax.TCArr (t1, t2)}
  | INT {Syntax.TVNum}
  | LPAR; t = typ; RPAR {t}
