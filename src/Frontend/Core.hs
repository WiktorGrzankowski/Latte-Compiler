module Frontend.Core where

import Data.Map as Map
import Control.Monad.Except
import Control.Monad.State
import Data.Map as Map
import Data.Set as Set
import Latte.AbsLatte
import Latte.ErrM
import Latte.SkelLatte
import Latte.PrintLatte
import Latte.ParLatte
type Pos = BNFC'Position
type Loc = Int
type Var = String
data CompilerError = CompilerError { text :: String, position :: Pos }
data VType = VInt | VStr | VBool | VVoid | VArr VType | VClass Var | VNull | VSelf
data FunT = FunT { funType :: VType, argTypes :: [VType] }
type Env = Map Var VType
type EnvFun = Map Var FunT
type EnvClass = Map Var Env
type EnvFunClass = Map Var EnvFun
data StmtCheck = StmtCheck { 
                            varEnv :: Env, 
                            funEnv :: EnvFun, 
                            classEnv :: EnvClass, 
                            classFunEnv :: EnvFunClass,
                            returnType :: VType, 
                            redefinedVars :: Set Var, 
                            retSet :: Bool,
                            currClass :: Var
                            }

type TypeCheckerMonad a = ExceptT CompilerError (State StmtCheck) a

instance Show CompilerError where
    show err = case (position err) of
        Just (line, column) -> "ERROR\n Type check: " ++ (text err) ++ "\nCheck your code at line " ++ show line ++ " column " ++ show column ++ "."
        Nothing -> "ERROR\n Type check: " ++ (text err)

instance Show VType where
    show VInt = "int"
    show VStr = "string"
    show VVoid = "void"
    show VBool = "bool"
    show (VArr vt) = "array [" ++ (show vt) ++ "]"
    show (VClass className) = "class " ++ (show className)
    show VNull = "null"
    show VSelf = "self"

areInts :: VType -> VType -> Bool
areInts VInt VInt = True
areInts _ _ = False

areBools :: VType -> VType -> Bool
areBools VBool VBool = True
areBools _ _ = False;

areStrs :: VType -> VType -> Bool
areStrs VStr VStr = True
areStrs _ _ = False

areArrs :: VType -> VType -> Bool
areArrs (VArr t1) (VArr t2) = areSameType t1 t2 
areArrs _ _ = False

getCommonType :: VType -> VType -> Maybe VType
getCommonType VStr VStr = Just VStr
getCommonType VInt VInt = Just VInt
getCommonType VBool VBool = Just VBool
getCommonType (VArr t1) (VArr t2) = 
    case getCommonType t1 t2 of
        Nothing -> Nothing
        Just vt -> Just vt
getCommonType (VClass x1) (VClass x2) = case x1 == x2 of
    True -> Just $ VClass x1
    False -> Nothing
-- treat nulls as if they can be any class
getCommonType (VClass vt) VNull = Just $ VClass vt
getCommonType VNull (VClass vt) = Just $ VClass vt
getCommonType VVoid VVoid = Just VVoid
getCommonType _ _ = Nothing



areSameType :: VType -> VType -> Bool
areSameType t1 t2 = case getCommonType t1 t2 of
    Just v -> True
    Nothing -> False

vTypeFromType :: Type -> VType
vTypeFromType (Int _) = VInt
vTypeFromType (Str _) = VStr
vTypeFromType (Bool _) = VBool
vTypeFromType (Void _) = VVoid
vTypeFromType (ArrT _ t) = VArr $ vTypeFromType t 
vTypeFromType (ClassT _ (Ident x)) = VClass $ x

matchType :: Pos -> VType -> VType -> TypeCheckerMonad ()
matchType pos actual expected = do
    case areSameType actual expected of
        True -> return ()
        False -> throwError $ CompilerError { text = "Could not match type " ++ (show actual) ++ " with expected " ++ (show expected) ++ ".", position = pos}

assertInt :: Pos -> VType -> TypeCheckerMonad ()
assertInt _ VInt = return ()
assertInt pos vt = throwError $ CompilerError { text = "Could not match type " ++ (show vt) ++ " with expected " ++ (show VInt) ++ ".", position = pos}

assertSameType :: Pos -> VType -> VType -> TypeCheckerMonad ()
assertSameType pos actual expected = case areSameType actual expected of
    True -> return ()
    False -> throwError $ CompilerError { text = "Could not match type " ++ (show actual) ++ " with expected " ++ (show expected) ++ ".", position = pos}