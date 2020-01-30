%token <string> ID
%token <int> NUM
%token <string> STR
%token UNIT
%token COMMA COL SCOL DOT
%token LAM
%token FIX
%token PUSH
%token LET BE TO IN
%token PM AS
%token PRODUCE

%token THUNK
%token FORCE
%token PRINT
%token WAIT
%token PLUS MINUS TIMES

%token TARR
%token TINT
%token TPROD
%token TSTR
%token TUNIT
%token TTHUNK
%token TPRODUCE
%token LPAR RPAR
%token LBRACE RBRACE
%token EOF

%right TARR
%left TPROD
%left PLUS MINUS
%left TIMES

%start <Syntax.expr> prog

%%

prog:
  | e = expr; EOF {e}

expr:
  | e = value {e}
  | UNIT {Syntax.EUnit}
  | PRINT; s = STR; SCOL; e = expr {Syntax.EPrint (s, e)}
  | WAIT; SCOL; e = expr {Syntax.EWait e}
  | PRODUCE; e = value {Syntax.EProduce e}
  | THUNK; LPAR; e = expr; RPAR {Syntax.EThunk e}
  | FORCE; v = expr {Syntax.EForce(v)}
  | LET; x = ID; BE; e1 = expr; IN; e2 = expr {Syntax.ELet (x, e1, e2)}
  | m = expr; TO; w = ID; IN; n = expr {Syntax.EEagerLet (m, w, n)}
  | v = expr; PUSH; m = expr {Syntax.EPush (v, m)}
  | LAM; LPAR; x = ID; COL; t = typ; RPAR; e = expr  {Syntax.ELambda (x, t, e)}
  | FIX; LBRACE; t = typ; RBRACE; LPAR; x = ID; DOT; e = expr; RPAR {Syntax.EFix (t, x, e)}
  | PM; e = expr; AS; LPAR; x = ID; COMMA; y = ID; RPAR; IN; m = expr {Syntax.EPMPair (e, (x, y), m)}
  | LPAR; e = expr; RPAR {e}

value:
  | n = NUM {Syntax.ENum n}
  | x = ID  {Syntax.EVar x}
  | a = value; PLUS;  b = value {Syntax.EPlus (a, b)}
  | a = value; MINUS; b = value {Syntax.EMinus (a, b)}
  | a = value; TIMES; b = value {Syntax.ETimes (a, b)}
  | s = STR {Syntax.EString(s)}
  | LPAR; e1 = expr; COMMA; e2 = expr; RPAR {Syntax.EPair (e1, e2)}

typ:
  | t1 = typ; TARR;  t2 = typ {Syntax.TCArr (t1, t2)}
  | TTHUNK; t = typ {Syntax.TVThunk t}
  | TPRODUCE; t = typ {Syntax.TCProduce t}
  | TINT {Syntax.TVNum}
  | TUNIT {Syntax.TVUnit}
  | TSTR {Syntax.TVString}
  | t1 = typ; TPROD; t2 = typ {Syntax.TVPair (t1, t2)}
  | LPAR; t = typ; RPAR {t}
