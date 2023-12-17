-- -*- haskell -*- File generated by the BNF Converter (bnfc 2.9.4).

-- Parser definition for use with Happy
{
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
{-# LANGUAGE PatternSynonyms #-}

module Latte.ParLatte
  ( happyError
  , myLexer
  , pProgram
  ) where

import Prelude

import qualified Latte.AbsLatte
import Latte.LexLatte

}

%name pProgram_internal Program
-- no lexer declaration
%monad { Err } { (>>=) } { return }
%tokentype {Token}
%token
  '!'           { PT _ (TS _ 1)  }
  '!='          { PT _ (TS _ 2)  }
  '%'           { PT _ (TS _ 3)  }
  '&&'          { PT _ (TS _ 4)  }
  '('           { PT _ (TS _ 5)  }
  ')'           { PT _ (TS _ 6)  }
  '*'           { PT _ (TS _ 7)  }
  '+'           { PT _ (TS _ 8)  }
  '++'          { PT _ (TS _ 9)  }
  ','           { PT _ (TS _ 10) }
  '-'           { PT _ (TS _ 11) }
  '--'          { PT _ (TS _ 12) }
  '.'           { PT _ (TS _ 13) }
  '/'           { PT _ (TS _ 14) }
  ':'           { PT _ (TS _ 15) }
  ';'           { PT _ (TS _ 16) }
  '<'           { PT _ (TS _ 17) }
  '<='          { PT _ (TS _ 18) }
  '='           { PT _ (TS _ 19) }
  '=='          { PT _ (TS _ 20) }
  '>'           { PT _ (TS _ 21) }
  '>='          { PT _ (TS _ 22) }
  '['           { PT _ (TS _ 23) }
  '[]'          { PT _ (TS _ 24) }
  ']'           { PT _ (TS _ 25) }
  'boolean'     { PT _ (TS _ 26) }
  'class'       { PT _ (TS _ 27) }
  'else'        { PT _ (TS _ 28) }
  'error'       { PT _ (TS _ 29) }
  'false'       { PT _ (TS _ 30) }
  'for'         { PT _ (TS _ 31) }
  'if'          { PT _ (TS _ 32) }
  'int'         { PT _ (TS _ 33) }
  'new'         { PT _ (TS _ 34) }
  'null'        { PT _ (TS _ 35) }
  'printInt'    { PT _ (TS _ 36) }
  'printString' { PT _ (TS _ 37) }
  'readInt'     { PT _ (TS _ 38) }
  'readString'  { PT _ (TS _ 39) }
  'return'      { PT _ (TS _ 40) }
  'string'      { PT _ (TS _ 41) }
  'true'        { PT _ (TS _ 42) }
  'void'        { PT _ (TS _ 43) }
  'while'       { PT _ (TS _ 44) }
  '{'           { PT _ (TS _ 45) }
  '||'          { PT _ (TS _ 46) }
  '}'           { PT _ (TS _ 47) }
  L_Ident       { PT _ (TV _)    }
  L_integ       { PT _ (TI _)    }
  L_quoted      { PT _ (TL _)    }

%%

Ident :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Ident) }
Ident  : L_Ident { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Ident (tokenText $1)) }

Integer :: { (Latte.AbsLatte.BNFC'Position, Integer) }
Integer  : L_integ  { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), (read (tokenText $1)) :: Integer) }

String  :: { (Latte.AbsLatte.BNFC'Position, String) }
String   : L_quoted { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), ((\(PT _ (TL s)) -> s) $1)) }

Program :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Program) }
Program
  : ListTopDef { (fst $1, Latte.AbsLatte.Prog (fst $1) (snd $1)) }

TopDef :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.TopDef) }
TopDef
  : Type Ident '(' ListArg ')' Block { (fst $1, Latte.AbsLatte.FnDef (fst $1) (snd $1) (snd $2) (snd $4) (snd $6)) }
  | 'class' Ident '{' ListClassAttr '}' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.ClassDef (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $2) (snd $4)) }

ClassAttr :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.ClassAttr) }
ClassAttr
  : Type Ident ';' { (fst $1, Latte.AbsLatte.ClassField (fst $1) (snd $1) (snd $2)) }

ListClassAttr :: { (Latte.AbsLatte.BNFC'Position, [Latte.AbsLatte.ClassAttr]) }
ListClassAttr
  : {- empty -} { (Latte.AbsLatte.BNFC'NoPosition, []) }
  | ClassAttr ListClassAttr { (fst $1, (:) (snd $1) (snd $2)) }

ListTopDef :: { (Latte.AbsLatte.BNFC'Position, [Latte.AbsLatte.TopDef]) }
ListTopDef
  : TopDef { (fst $1, (:[]) (snd $1)) }
  | TopDef ListTopDef { (fst $1, (:) (snd $1) (snd $2)) }

Arg :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Arg) }
Arg
  : Type Ident { (fst $1, Latte.AbsLatte.Ar (fst $1) (snd $1) (snd $2)) }

ListArg :: { (Latte.AbsLatte.BNFC'Position, [Latte.AbsLatte.Arg]) }
ListArg
  : {- empty -} { (Latte.AbsLatte.BNFC'NoPosition, []) }
  | Arg { (fst $1, (:[]) (snd $1)) }
  | Arg ',' ListArg { (fst $1, (:) (snd $1) (snd $3)) }

Block :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Block) }
Block
  : '{' ListStmt '}' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Blk (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $2)) }

ListStmt :: { (Latte.AbsLatte.BNFC'Position, [Latte.AbsLatte.Stmt]) }
ListStmt
  : {- empty -} { (Latte.AbsLatte.BNFC'NoPosition, []) }
  | Stmt ListStmt { (fst $1, (:) (snd $1) (snd $2)) }

Stmt :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Stmt) }
Stmt
  : ';' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Empty (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | Block { (fst $1, Latte.AbsLatte.BStmt (fst $1) (snd $1)) }
  | Type ListItem ';' { (fst $1, Latte.AbsLatte.Decl (fst $1) (snd $1) (snd $2)) }
  | Expr6 '=' Expr ';' { (fst $1, Latte.AbsLatte.Ass (fst $1) (snd $1) (snd $3)) }
  | Expr6 '++' ';' { (fst $1, Latte.AbsLatte.Incr (fst $1) (snd $1)) }
  | Expr6 '--' ';' { (fst $1, Latte.AbsLatte.Decr (fst $1) (snd $1)) }
  | 'return' Expr ';' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Ret (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $2)) }
  | 'return' ';' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.VRet (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | 'if' '(' Expr ')' Stmt { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Cond (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $3) (snd $5)) }
  | 'if' '(' Expr ')' Stmt 'else' Stmt { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.CondElse (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $3) (snd $5) (snd $7)) }
  | 'while' '(' Expr ')' Stmt { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.While (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $3) (snd $5)) }
  | 'for' '(' Type Ident ':' Ident ')' Stmt { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.ForEach (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $3) (snd $4) (snd $6) (snd $8)) }
  | Expr ';' { (fst $1, Latte.AbsLatte.SExp (fst $1) (snd $1)) }
  | 'printInt' '(' Expr ')' ';' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.SPrintInt (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $3)) }
  | 'printString' '(' Expr ')' ';' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.SPrintStr (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $3)) }
  | 'error' '(' ')' ';' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Error (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }

Item :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Item) }
Item
  : Ident { (fst $1, Latte.AbsLatte.NoInit (fst $1) (snd $1)) }
  | Ident '=' Expr { (fst $1, Latte.AbsLatte.Init (fst $1) (snd $1) (snd $3)) }

ListItem :: { (Latte.AbsLatte.BNFC'Position, [Latte.AbsLatte.Item]) }
ListItem
  : Item { (fst $1, (:[]) (snd $1)) }
  | Item ',' ListItem { (fst $1, (:) (snd $1) (snd $3)) }

Type :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Type) }
Type
  : 'int' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Int (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | 'string' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Str (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | 'boolean' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Bool (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | 'void' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Void (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | Type '[]' { (fst $1, Latte.AbsLatte.ArrT (fst $1) (snd $1)) }
  | Ident { (fst $1, Latte.AbsLatte.ClassT (fst $1) (snd $1)) }

ListType :: { (Latte.AbsLatte.BNFC'Position, [Latte.AbsLatte.Type]) }
ListType
  : {- empty -} { (Latte.AbsLatte.BNFC'NoPosition, []) }
  | Type { (fst $1, (:[]) (snd $1)) }
  | Type ',' ListType { (fst $1, (:) (snd $1) (snd $3)) }

Expr6 :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Expr) }
Expr6
  : Ident { (fst $1, Latte.AbsLatte.EVar (fst $1) (snd $1)) }
  | 'null' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.ENull (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | Expr6 '[' Expr ']' { (fst $1, Latte.AbsLatte.EVarArr (fst $1) (snd $1) (snd $3)) }
  | Integer { (fst $1, Latte.AbsLatte.ELitInt (fst $1) (snd $1)) }
  | 'true' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.ELitTrue (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | 'false' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.ELitFalse (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | Ident '(' ListExpr ')' { (fst $1, Latte.AbsLatte.EApp (fst $1) (snd $1) (snd $3)) }
  | String { (fst $1, Latte.AbsLatte.EString (fst $1) (snd $1)) }
  | 'new' Type '[' Expr ']' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.EArr (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $2) (snd $4)) }
  | 'new' Ident '[' Expr ']' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.EArrClass (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $2) (snd $4)) }
  | 'new' Ident { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.EClass (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $2)) }
  | Expr6 '.' Ident { (fst $1, Latte.AbsLatte.EAttr (fst $1) (snd $1) (snd $3)) }
  | '(' Expr ')' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), (snd $2)) }

Expr5 :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Expr) }
Expr5
  : '-' Expr6 { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Neg (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $2)) }
  | '!' Expr6 { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Not (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1)) (snd $2)) }
  | Expr6 { (fst $1, (snd $1)) }

Expr4 :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Expr) }
Expr4
  : Expr4 MulOp Expr5 { (fst $1, Latte.AbsLatte.EMul (fst $1) (snd $1) (snd $2) (snd $3)) }
  | Expr5 { (fst $1, (snd $1)) }

Expr3 :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Expr) }
Expr3
  : Expr3 AddOp Expr4 { (fst $1, Latte.AbsLatte.EAdd (fst $1) (snd $1) (snd $2) (snd $3)) }
  | Expr4 { (fst $1, (snd $1)) }

Expr2 :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Expr) }
Expr2
  : Expr2 RelOp Expr3 { (fst $1, Latte.AbsLatte.ERel (fst $1) (snd $1) (snd $2) (snd $3)) }
  | Expr3 { (fst $1, (snd $1)) }

Expr1 :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Expr) }
Expr1
  : Expr2 '&&' Expr1 { (fst $1, Latte.AbsLatte.EAnd (fst $1) (snd $1) (snd $3)) }
  | Expr2 { (fst $1, (snd $1)) }

Expr :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.Expr) }
Expr
  : Expr1 '||' Expr { (fst $1, Latte.AbsLatte.EOr (fst $1) (snd $1) (snd $3)) }
  | 'readInt' '(' ')' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.SReadInt (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | 'readString' '(' ')' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.SReadStr (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | Expr1 { (fst $1, (snd $1)) }

ListExpr :: { (Latte.AbsLatte.BNFC'Position, [Latte.AbsLatte.Expr]) }
ListExpr
  : {- empty -} { (Latte.AbsLatte.BNFC'NoPosition, []) }
  | Expr { (fst $1, (:[]) (snd $1)) }
  | Expr ',' ListExpr { (fst $1, (:) (snd $1) (snd $3)) }

AddOp :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.AddOp) }
AddOp
  : '+' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Plus (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | '-' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Minus (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }

MulOp :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.MulOp) }
MulOp
  : '*' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Times (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | '/' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Div (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | '%' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.Mod (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }

RelOp :: { (Latte.AbsLatte.BNFC'Position, Latte.AbsLatte.RelOp) }
RelOp
  : '<' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.LTH (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | '<=' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.LE (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | '>' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.GTH (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | '>=' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.GE (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | '==' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.EQU (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }
  | '!=' { (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1), Latte.AbsLatte.NE (uncurry Latte.AbsLatte.BNFC'Position (tokenLineCol $1))) }

{

type Err = Either String

happyError :: [Token] -> Err a
happyError ts = Left $
  "syntax error at " ++ tokenPos ts ++
  case ts of
    []      -> []
    [Err _] -> " due to lexer error"
    t:_     -> " before `" ++ (prToken t) ++ "'"

myLexer :: String -> [Token]
myLexer = tokens

-- Entrypoints

pProgram :: [Token] -> Err Latte.AbsLatte.Program
pProgram = fmap snd . pProgram_internal
}

