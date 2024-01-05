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
import Data.List.Split (splitOn)

type Pos = BNFC'Position
type Loc = Int
type Var = String
data CompilerError = CompilerError { text :: String, position :: Pos }
data TType = TInt | TStr | TBool | TVoid | TArr TType | TClass Var | TNull
data VType = VInt Integer | VStr String | VBool Bool | VArr VType
data FunT = FunT { funType :: VType, argTypes :: [VType] }
type Env = Map Var (Integer, TType)
type EnvFun = Map Var [(String, Type)]
type EnvFunClass = Map Var EnvFun
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
                         classFunEnv :: EnvFunClass,
                         classSuperclasses :: EnvSuperclasses,
                         stackSize :: Integer, 
                         funArgs :: [(String, Type)], 
                         hardcodedStrs :: Map Var String, 
                         labelId :: Integer,
                         funId :: Integer,
                         currClass :: Var
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

divideReg :: String -> Builder
divideReg reg = fromString $ "   idiv " ++ reg ++ "\n"

xorRegs :: String -> String -> Builder
xorRegs reg1 reg2 = fromString $ "   xor " ++ reg1 ++ ", " ++ reg2 ++ "\n"

andRegs :: String -> String -> Builder
andRegs reg1 reg2 = fromString $ "   and " ++ reg1 ++ ", " ++ reg2 ++ "\n"

compareRegs :: String -> String -> Builder
compareRegs reg1 reg2 = fromString $ "   cmp " ++ reg1 ++ ", " ++ reg2 ++ "\n"

movToRegString :: String -> String -> Builder
movToRegString reg str = fromString $ "   mov " ++ reg ++ ", " ++ str ++ "\n"

movToRegDefaultString :: String -> Builder
movToRegDefaultString reg = fromString $ "   mov " ++ reg ++ ", s0\n"

movToRegFromRegVal :: String -> String -> Builder
movToRegFromRegVal reg1 reg2 = fromString $ "   mov " ++ reg1 ++ ", [" ++ reg2 ++ "]\n"

movToRegFromReg :: String -> String -> Builder
movToRegFromReg reg1 reg2 = fromString $ "   mov " ++ reg1 ++ ", " ++ reg2 ++ "\n"

movToRegFromStack :: String -> Integer -> Builder
movToRegFromStack reg offset = fromString $ "   mov " ++ reg ++ ", [rbp - " ++ (show offset) ++ "]\n" 

movToRegSelfArg :: String -> Builder
movToRegSelfArg reg = fromString $ "   mov " ++ reg ++ ", [rbp - 8]\n"

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

getMethodIdent :: Var -> String -> String
getMethodIdent className methodName = className ++ "_$_" ++ methodName

getMethodNameFromIdent :: String -> String
getMethodNameFromIdent ident = 
    case splitOn "_$_" ident of
        (_:method:_) -> method 
        _ -> ""  

getClassNameFromIdent :: String -> String
getClassNameFromIdent ident =
    case splitOn "_$_" ident of
        (className:_) -> className
        _ -> ""

-- it will always find it as type check was successful
getMethodIdentInSuperclassses :: Var -> String -> [Var] -> CM String
getMethodIdentInSuperclassses className methodName [] = return $ getMethodIdent className methodName
getMethodIdentInSuperclassses className methodName (super:others) = do
    memory <- get
    -- get method names in superclass
    let superFunEnv = Map.findWithDefault Map.empty super (classFunEnv memory)
    let nameForSuper = getMethodIdent super methodName
    case Map.lookup nameForSuper superFunEnv of
        Nothing -> getMethodIdentInSuperclassses className methodName others
        Just _ -> return nameForSuper

getArgsFromSuperclassMethods :: Var -> String -> CM [(String, Type)]
getArgsFromSuperclassMethods className methodName = do
    -- first get the class that has this method
    allSuperclasses <- gets classSuperclasses
    let thisClassSupers = Map.findWithDefault [] className allSuperclasses
    -- get the correct ident
    methodIdent <- getMethodIdentInSuperclassses className methodName thisClassSupers
    -- get class owning the method from ident
    let classOwnerName = getClassNameFromIdent methodIdent
    -- no get args
    funs <- gets classFunEnv
    let ownerClassMethods = Map.findWithDefault Map.empty classOwnerName funs
    return $ Map.findWithDefault [] methodIdent ownerClassMethods