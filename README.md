# Levy Language Interpreter
Simple typechecker and interpreter for Levy Language.
This implementation includes (See: tlca99.pdf, Fig. 1. Terms of Basic
Language, and Big-Step Semantics):
 - produce
 - thunk
 - lambda (pop value)
 - let x be e in e'
 - generalized let: M to x in N
 - force V
 - V'M (push value into the stack)
 - Arithmetics expressions

As it was noted in 'tlca99.pdf: Remark 1.', A language with
arithmetics expression is a bit more complicated because
'produce V' cannot be readed as a value directly. In this
implementation the 'produce V' is treated just as a 'almost value'.
It means that if 'V' (in produce V) is an arithmetics expression,
it will be evaluated.

The version with Arithmetics Expression was chosen because:
 - It is enough to interprete and write examples as it is in
   tlca99.pdf: '2.3 Example Computation'.
 - With this set of constructors/types it is possible to see the main
   Levy's CBPV idea - The single language which includes both CBN and
   CBV function space (outlines in tlca99.pdf, See 'Fig. 3', 'Fig. 4').

This implementation can be easily enriched by more constructors e.q:
 - if then else
 - case
 - pattern matching (not needed in this project, mentioned in tlca99.pdf)
 - rec
 - tuples, projections, sum of types and so on.

# Compilation

Using ocamlbuild is recommended. The parser is written using the
menhir parser generator library. Both packages can be installed using
opam, OCaml's package manager. In this case, the project can be built
with the following invocation:

$ ocamlbuild -use-menhir main.native -pkgs str

This command will produce the executable 'main.native'. Compilation
was tested on a unix system with OCaml v.4.05.0. It should work on
other versions and platforms, but mileage may vary.

# Usage

The interpreter is called as follows:

$ ./main.native filename

To make runtime legible, the output of interpreter is divided into three sections:
 - typechecker - the type of the program (computation).
 - evaluator - all output produced by print are here.
 - result of the program - e.q 'produce 15'


An example showcasing most language constructs can be found in the
file 'examples/example00.levy'. In 'examples/', you can also find
another simple programs to verify interpreter.
