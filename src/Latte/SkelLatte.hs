-- File generated by the BNF Converter (bnfc 2.9.4).

-- Templates for pattern matching on abstract syntax

{-# OPTIONS_GHC -fno-warn-unused-matches #-}

module Latte.SkelLatte where

import Prelude (($), Either(..), String, (++), Show, show)
import qualified Latte.AbsLatte

type Err = Either String
type Result = Err String

failure :: Show a => a -> Result
failure x = Left $ "Undefined case: " ++ show x

transIdent :: Latte.AbsLatte.Ident -> Result
transIdent x = case x of
  Latte.AbsLatte.Ident string -> failure x

transProgram :: Show a => Latte.AbsLatte.Program' a -> Result
transProgram x = case x of
  Latte.AbsLatte.Prog _ topdefs -> failure x

transTopDef :: Show a => Latte.AbsLatte.TopDef' a -> Result
transTopDef x = case x of
  Latte.AbsLatte.FnDef _ type_ ident args block -> failure x
  Latte.AbsLatte.ClassDef _ ident classattrs -> failure x

transClassAttr :: Show a => Latte.AbsLatte.ClassAttr' a -> Result
transClassAttr x = case x of
  Latte.AbsLatte.ClassField _ type_ ident -> failure x

transArg :: Show a => Latte.AbsLatte.Arg' a -> Result
transArg x = case x of
  Latte.AbsLatte.Ar _ type_ ident -> failure x

transBlock :: Show a => Latte.AbsLatte.Block' a -> Result
transBlock x = case x of
  Latte.AbsLatte.Blk _ stmts -> failure x

transStmt :: Show a => Latte.AbsLatte.Stmt' a -> Result
transStmt x = case x of
  Latte.AbsLatte.Empty _ -> failure x
  Latte.AbsLatte.BStmt _ block -> failure x
  Latte.AbsLatte.Decl _ type_ items -> failure x
  Latte.AbsLatte.Ass _ expr1 expr2 -> failure x
  Latte.AbsLatte.Incr _ expr -> failure x
  Latte.AbsLatte.Decr _ expr -> failure x
  Latte.AbsLatte.Ret _ expr -> failure x
  Latte.AbsLatte.VRet _ -> failure x
  Latte.AbsLatte.Cond _ expr stmt -> failure x
  Latte.AbsLatte.CondElse _ expr stmt1 stmt2 -> failure x
  Latte.AbsLatte.While _ expr stmt -> failure x
  Latte.AbsLatte.ForEach _ type_ ident1 ident2 stmt -> failure x
  Latte.AbsLatte.SExp _ expr -> failure x
  Latte.AbsLatte.SPrintInt _ expr -> failure x
  Latte.AbsLatte.SPrintStr _ expr -> failure x
  Latte.AbsLatte.Error _ -> failure x

transItem :: Show a => Latte.AbsLatte.Item' a -> Result
transItem x = case x of
  Latte.AbsLatte.NoInit _ ident -> failure x
  Latte.AbsLatte.Init _ ident expr -> failure x

transType :: Show a => Latte.AbsLatte.Type' a -> Result
transType x = case x of
  Latte.AbsLatte.Int _ -> failure x
  Latte.AbsLatte.Str _ -> failure x
  Latte.AbsLatte.Bool _ -> failure x
  Latte.AbsLatte.Void _ -> failure x
  Latte.AbsLatte.ArrT _ type_ -> failure x
  Latte.AbsLatte.ClassT _ ident -> failure x
  Latte.AbsLatte.Fun _ type_ types -> failure x

transExpr :: Show a => Latte.AbsLatte.Expr' a -> Result
transExpr x = case x of
  Latte.AbsLatte.EVar _ ident -> failure x
  Latte.AbsLatte.ENull _ -> failure x
  Latte.AbsLatte.EVarArr _ expr1 expr2 -> failure x
  Latte.AbsLatte.ELitInt _ integer -> failure x
  Latte.AbsLatte.ELitTrue _ -> failure x
  Latte.AbsLatte.ELitFalse _ -> failure x
  Latte.AbsLatte.EApp _ ident exprs -> failure x
  Latte.AbsLatte.EString _ string -> failure x
  Latte.AbsLatte.EArr _ type_ expr -> failure x
  Latte.AbsLatte.EArrClass _ ident expr -> failure x
  Latte.AbsLatte.EClass _ ident -> failure x
  Latte.AbsLatte.EAttr _ expr ident -> failure x
  Latte.AbsLatte.Neg _ expr -> failure x
  Latte.AbsLatte.Not _ expr -> failure x
  Latte.AbsLatte.EMul _ expr1 mulop expr2 -> failure x
  Latte.AbsLatte.EAdd _ expr1 addop expr2 -> failure x
  Latte.AbsLatte.ERel _ expr1 relop expr2 -> failure x
  Latte.AbsLatte.EAnd _ expr1 expr2 -> failure x
  Latte.AbsLatte.EOr _ expr1 expr2 -> failure x
  Latte.AbsLatte.SReadInt _ -> failure x
  Latte.AbsLatte.SReadStr _ -> failure x

transAddOp :: Show a => Latte.AbsLatte.AddOp' a -> Result
transAddOp x = case x of
  Latte.AbsLatte.Plus _ -> failure x
  Latte.AbsLatte.Minus _ -> failure x

transMulOp :: Show a => Latte.AbsLatte.MulOp' a -> Result
transMulOp x = case x of
  Latte.AbsLatte.Times _ -> failure x
  Latte.AbsLatte.Div _ -> failure x
  Latte.AbsLatte.Mod _ -> failure x

transRelOp :: Show a => Latte.AbsLatte.RelOp' a -> Result
transRelOp x = case x of
  Latte.AbsLatte.LTH _ -> failure x
  Latte.AbsLatte.LE _ -> failure x
  Latte.AbsLatte.GTH _ -> failure x
  Latte.AbsLatte.GE _ -> failure x
  Latte.AbsLatte.EQU _ -> failure x
  Latte.AbsLatte.NE _ -> failure x
