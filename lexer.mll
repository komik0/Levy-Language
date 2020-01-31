{
open Lexing
open Parser
}

let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let num = ['-']? ['0'-'9']+
let id = ['a'-'z' 'A'-'Z'] ['a'-'z' 'A'-'Z' '0'-'9' '\'']*
let str = '\"' [^'\"']* '\"'

rule read =
  parse
  | white {read lexbuf}
  | newline {new_line lexbuf; read lexbuf}
  | num {NUM (int_of_string (Lexing.lexeme lexbuf))}
  | "λ" {LAM}
  | "let" {LET}
  | "be" {BE}
  | "to" {TO}
  | "in" {IN}
  | "int"  {TINT}
  | "str"  {TSTR}
  | "unit"  {TUNIT}
  | "pm" {PM}
  | "as" {AS}
  | "ifz" {IFZ}
  | "then" {THEN}
  | "else" {ELSE}
  | "zfi" {ZFI}
  | "produce" {PRODUCE}
  | "force" {FORCE}
  | "thunk" {THUNK}
  | "print" {PRINT}
  | "wait" {WAIT}
  | "fix" {FIX}
  | "{" {LBRACE}
  | "}" {RBRACE}
  | "F" {TPRODUCE}
  | "U" {TTHUNK}
  | str {STR (Lexing.lexeme lexbuf)}
  | "'" {PUSH}
  | "," {COMMA}
  | "." {DOT}
  | ":" {COL}
  | ";" {SCOL}
  | "->" {TARR}
  | "+"  {PLUS}
  | "-"  {MINUS}
  | "*"  {TIMES}
  | "×" {TPROD}
  | "()" {UNIT}
  | "(" {LPAR}
  | ")" {RPAR}
  | id {ID (Lexing.lexeme lexbuf)}
  | _ {failwith ("Unexpected char: " ^ Lexing.lexeme lexbuf)}
  | eof {EOF}
