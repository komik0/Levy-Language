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
 - pair
 - string
 - pm (v,v) as (x, y) in M
 - fix {B} (x.e)
 - ifz (e; m; x.m')
 - wait


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
 - bool
 - case
 - sum of types
 - pattern matching (generalized - not needed in this project, mentioned in tlca99.pdf) and so on...

# Why Levy Language?
It is well-known problem that result of programs computed in CBV and CBN can be different.
For instance, lets consider a simple language with
 - lambda,
 - application,
 - var, nat, and plus.

and then consider following program:

  ```ap(lam(x)lam(y) 1 + x + y)(2+3)```

In CBV it evaluates to

  ```lam(y) 1 + 5 + y```

Whereas, in CBN it will be

  ```lam(y) 1 + 2 + 3 + y```

In short, (and not exactly) to get rid of above differences P.B. Levy allows programmers
to chose between CBN and CBV reduction strategy. To do so, he introduced two constructors
'thunk' for construct value, and 'force' to force compute of value - for example if int were
a computation type, force(thunk(2+3)) would evaluate to 5, whereas thunk(2+3) would be just thunk(2+3).
To catch this idea following example outlines translation to CBPV:

  CBV -> CBPV:
    ```ap(lam(x)lam(y) 1 + x + y)(force(thunk(2+3))) -> lam(y) 1 + 5 + y```

  CBN -> CBPV:
    ```ap(lam(x)lam(y) 1 + x + y)(thunk(2+3)) -> lam(y) 1 + thunk(2+3) + y```

Of course there are an type and other errors above - it is just outline.
With above idea - as it is noted in tlca99.pdf - CBPV subsumes both CBN and CBV.

Reader may wonder why it is called CBPV, (why not e.q. CBTF - Call by Thunk Force :)).
To answer above and another questions please read examples00.levy or/and

  https://www.cs.bham.ac.uk/~pbl/cbpv.html

# Compilation

Using ocamlbuild is recommended. The parser is written using the
menhir parser generator library. Both packages can be installed using
opam, OCaml's package manager. In this case, the project can be built
with the following invocation:

```$ ocamlbuild -use-menhir main.native -pkgs str```

This command will produce the executable 'main.native'. Compilation
was tested on a unix system with OCaml v.4.05.0. It should work on
other versions and platforms, but mileage may vary.

# Usage

The interpreter is called as follows:

```$ ./main.native filename```

To make runtime legible, the output of interpreter is divided into three sections:
 - typechecker - the type of the program (computation).
 - evaluator - all output produced by print are here.
 - result of the program - e.q 'produce 15'


An example showcasing most language constructs can be found in the
file 'examples/example00.levy'. In 'examples/', you can also find
another simple programs to verify interpreter.

# Testing
You can verify interpreter automatically by:

```$ ./run_test.sh```

It runs some programs in 'examples/' for eq. factorial function.
Of course, you also can write your own interpreter tests.

If you have any question or tests or so,
please do not hesitate to contact me.
