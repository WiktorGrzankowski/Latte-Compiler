module Backend.Core where

import System.IO
import Control.Monad.Except
import Control.Monad.State
import Data.Map as Map
import Data.Set as Set
import Latte.AbsLatte
import Latte.ErrM
import Latte.SkelLatte
import Latte.PrintLatte
import Latte.ParLatte
import Data.Text.Lazy.Builder

type Pos = BNFC'Position
type Loc = Int
type Var = String
data CompilerError = CompilerError { text :: String, position :: Pos }
data TType = TInt | TStr | TBool | TVoid | TArr TType | TClass Var | TNull
data VType = VInt Integer | VStr String | VBool Bool | VArr VType
data FunT = FunT { funType :: VType, argTypes :: [VType] }
type Env = Map Var (Integer, TType)
type EnvFun = Map Var [(String, Type)]
type EnvFunTypes = Map Var TType
type EnvClass = Map Var Env
type EnvSuperclasses = Map Var [Var]

instance Show TType where
    show TInt = "int"
    show TStr = "string"
    show TVoid = "void"
    show TBool = "bool"
    show (TArr vt) = "array [" ++ (show vt) ++ "]"
    show (TClass var) = "class (" ++ (show var) ++ ")"

data StmtState = StmtState { varEnv :: Env, 
                         funEnv :: EnvFun, 
                         funEnvTypes :: EnvFunTypes,
                         classEnv :: EnvClass,
                         classSuperclasses :: EnvSuperclasses,
                         stackSize :: Integer, 
                         funArgs :: [(String, Type)], 
                         hardcodedStrs :: Map Var String, 
                         labelId :: Integer, 
                         funId :: Integer
                        }

type CM a = ExceptT CompilerError (StateT StmtState IO) a

instance Show CompilerError where
    show err = case (position err) of
        Just (line, column) -> "ERROR\n Type check: " ++ (text err) ++ "\nCheck your code at line " ++ show line ++ " column " ++ show column ++ "."
        Nothing -> "ERROR\n Type check: " ++ (text err)

formatStrings :: [Builder] -> Builder
formatStrings = Prelude.foldr (<>) mempty

typeSize :: Type -> Int
typeSize t = 8

popReg :: String -> Builder
popReg reg = fromString $ "   pop " ++ reg ++ "\n"


pushReg :: String -> Builder
pushReg reg = fromString $ "   push " ++ reg ++ "\n"

movToRegFromReg :: String -> String -> Builder
movToRegFromReg reg1 reg2 = fromString $ "   mov " ++ reg1 ++ ", " ++ reg2 ++ "\n"

movToRegFromStack :: String -> Integer -> Builder
movToRegFromStack reg offset = fromString $ "   mov " ++ reg ++ ", [rbp - " ++ (show offset) ++ "]\n" 

movToRegLiteralInt :: String -> Integer -> Builder
movToRegLiteralInt reg i = fromString $ "   mov " ++ reg ++ ", " ++ (show i) ++ "\n"

movToRegLiteralBool :: String -> Integer -> Builder
movToRegLiteralBool reg b = fromString $ "   mov " ++ reg ++ ", " ++ (show b) ++ "\n"

movToStackFromReg :: Integer -> String -> Builder
movToStackFromReg offset reg = fromString $ "   mov [rbp - " ++ (show offset) ++ "], " ++ reg ++ "\n"

areBothStrings :: TType -> TType -> Bool
areBothStrings TStr TStr = True
areBothStrings _ _ = False


raxPartBytes :: Int -> String
raxPartBytes i = "rax"

argRegister :: Integer -> Int -> String
argRegister argNr size
    | argNr == 1 = "rdi"
    | argNr == 2 = "rsi"
    | argNr == 3 = "rdx"
    | argNr == 4 = "rcx"
    | argNr == 5 = "r8"
    | otherwise = "r9"

tTypeFromType :: Type -> TType
tTypeFromType (Void _) = TVoid
tTypeFromType (Int _) = TInt
tTypeFromType (Str _) = TStr
tTypeFromType (Bool _) = TBool
tTypeFromType (ArrT _ t) = TArr $ tTypeFromType t
tTypeFromType (ClassT _ (Ident x)) = TClass x

allocateStack :: Integer -> Builder
allocateStack i = fromString $ "   sub rsp, " ++ (show i) ++ "\n"

alloc :: Map Var String -> String
alloc strs = "s" ++ (show $ Map.size strs)