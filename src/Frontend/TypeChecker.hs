module Frontend.TypeChecker where

import Frontend.Core
import Frontend.ExpChecker (checkExp)
import Frontend.ItemsChecker (checkItems)

import Control.Monad.Except
import Control.Monad.State
import Data.Map as Map
import Data.Set as Set
import Latte.AbsLatte
import Latte.ErrM
import Latte.SkelLatte
import Latte.PrintLatte
import Latte.ParLatte

emptyState :: StmtCheck
emptyState = StmtCheck { varEnv = Map.empty, funEnv = Map.empty, classEnv = Map.empty, returnType = VVoid, redefinedVars = Set.empty, retSet = False }

checkAll :: [TopDef] -> TypeCheckerMonad ()
checkAll topDefs = do
    mapM_ preProdTopDefs topDefs
    memory <- get
    case Map.lookup "main" (funEnv memory) of
        Just fun -> do
            case funType fun of
                VInt -> case argTypes fun of 
                    [] -> mapM_ checkTopDef topDefs
                    args -> throwError $ CompilerError { text = "Function int main() is not defined.", position = Nothing }
                _ -> throwError $ CompilerError { text = "Function int main() is not defined.", position = Nothing }
        Nothing -> throwError $ CompilerError { text = "Function int main() is not defined.", position = Nothing }

preProdTopDefs :: TopDef -> TypeCheckerMonad ()
preProdTopDefs (FnDef pos fType (Ident f) args block) = do
    memory <- get
    case Map.lookup f (funEnv memory) of
        Nothing -> do
            (varsInFun, funArgTypes, redefArgs) <- parseArgs args (varEnv memory)
            let newFun = FunT { funType = vTypeFromType fType, argTypes = funArgTypes }
            let newFunEnv = Map.insert f newFun (funEnv memory)
            modify (\st -> st { funEnv = newFunEnv })
        Just _ -> throwError $ CompilerError { text = "Function " ++ (show f) ++ " is already defined.", position = Nothing }

preProdTopDefs (ClassDef pos (Ident x) attrs) = do
    localEnv <- parseAttrs attrs
    memory <- get
    case Map.lookup x (classEnv memory) of
        Nothing -> modify (\st -> st { classEnv = Map.insert x localEnv (classEnv st) })
        Just _ -> throwError $ CompilerError { text = "Class " ++ (show x) ++ " is already defined.", position = Nothing }

parseAttrs :: [ClassAttr] -> TypeCheckerMonad Env
parseAttrs attrs = go attrs Map.empty where
    go :: [ClassAttr] -> Env -> TypeCheckerMonad Env
    go [] m = return m
    go ((ClassField pos t (Ident x)):rest) m =
        case Map.lookup x m of
            Nothing -> go rest (Map.insert x (vTypeFromType t) m)
            _ ->  throwError $ CompilerError { text = "Class field " ++ (show x) ++ " defined multiple times.", position = pos }

checkTopDef :: TopDef -> TypeCheckerMonad ()
checkTopDef (FnDef pos fType (Ident f) args block) = do
    memory <- get
    let vars = varEnv memory -- maybe useless
    -- add arguments as local variables
    (varsInFun, funArgTypes, redefArgs) <- parseArgs args (varEnv memory)
    let newFun = FunT { funType = vTypeFromType fType, argTypes = funArgTypes }
    let newFunEnv = Map.insert f newFun (funEnv memory)
    let redefVars = redefinedVars memory
    modify (\st -> st { varEnv = varsInFun, funEnv = newFunEnv, returnType = vTypeFromType fType, redefinedVars = redefArgs, retSet = False })
    checkBlock block True
    isRetSet <- gets retSet
    case isRetSet of
        False -> case (vTypeFromType fType) of
            VVoid -> modify (\st -> st {varEnv = vars, funEnv = newFunEnv, returnType = returnType memory, redefinedVars = redefVars, retSet = False })
            _ -> throwError $ CompilerError { text = "Function " ++ (show f) ++ " does not end with a return statement.", position = pos }
        True -> modify (\st -> st { varEnv = vars, funEnv = newFunEnv, returnType = returnType memory, redefinedVars = redefVars, retSet = False })

-- nothing more required after preprocessing
checkTopDef (ClassDef pos (Ident x) attrs) = return ()
    

parseArgs :: [Arg] -> Env -> TypeCheckerMonad (Env, [VType], Set Var) 
parseArgs args e = go args (e, [], Set.empty) where
    go :: [Arg] -> (Env, [VType], Set Var) -> TypeCheckerMonad (Env, [VType], Set Var)
    go [] (env, ts, redef) = return (env, ts, redef)
    go ((Ar pos t (Ident x)):rest) (env, ts, redef) = 
        case Set.member x redef of
            False -> go rest ((Map.insert x (vTypeFromType t) env), (vTypeFromType t):ts, Set.insert x redef)
            True -> throwError $ CompilerError { text = "Argument " ++ (show x) ++ " is defined twice in a function definition.", position = pos }

checkBlock :: Block -> Bool -> TypeCheckerMonad ()
checkBlock (Blk _ stmts) funArgsRedefined = do
    memory <- get
    let redefArgs = if funArgsRedefined == True then redefinedVars memory else Set.empty
    modify (\st -> st { redefinedVars = redefArgs})
    mapM_ checkStmt stmts
    -- forget all variables initialized within the block
    isRetSet <- gets retSet
    modify (\st -> st { varEnv = varEnv memory, funEnv = funEnv memory, returnType = returnType memory, redefinedVars = redefinedVars memory, retSet = isRetSet})
    return ()


branchBlock (BStmt _ b) pos = checkBlock b True
branchBlock stmt pos = checkBlock (Blk pos [stmt]) True

checkStmt :: Stmt -> TypeCheckerMonad ()
checkStmt (Empty _) = return ()

checkStmt (Decl _ dType items) = checkItems dType items >> return ()

checkStmt (Decr pos e) = checkStmt (Incr pos e)

checkStmt (Incr pos1 (EVar pos2 x)) = do
    varType <- checkExp (EVar pos2 x)
    assertInt pos1 varType
checkStmt (Incr pos1 (EVarArr pos2 e1 e2)) = do
    varType <- checkExp (EVarArr pos2 e1 e2)
    assertInt pos1 varType
checkStmt (Incr pos1 (EAttr pos2 e id)) = do
    varType <- checkExp (EAttr pos2 e id)
    assertInt pos1 varType
checkStmt (Incr pos _) = throwError $ CompilerError { text = "(++) and (--) operations can only be called on variables of type int.", position = pos }

            
checkStmt (Cond pos (ELitTrue _) stmt) = do
    redefBefore <- gets redefinedVars
    modify (\st -> st { redefinedVars = Set.empty })
    branchBlock stmt pos
    modify (\st -> st { redefinedVars = redefBefore })

checkStmt (Cond pos cond stmt) = do
    condT <- checkExp cond
    case condT of
        VBool -> do
            memory <- get
            modify (\st -> st { redefinedVars = Set.empty })
            branchBlock stmt pos
            put (memory)
        _ -> throwError $ CompilerError { text = "Logical condition must be a boolean expression.", position = pos }

checkStmt (CondElse pos (ELitTrue _) stmt1 _) = do
    redefBefore <- gets redefinedVars
    modify (\st -> st { redefinedVars = Set.empty })
    branchBlock stmt1 pos
    modify (\st -> st { redefinedVars = redefBefore })

checkStmt (CondElse pos (ELitFalse _) _ stmt2) = do
    redefBefore <- gets redefinedVars
    modify (\st -> st { redefinedVars = Set.empty })
    branchBlock stmt2 pos
    modify (\st -> st { redefinedVars = redefBefore })

checkStmt (CondElse pos cond stmt1 stmt2) = do
    condT <- checkExp cond
    case condT of
        VBool -> do
            retBefore <- gets retSet
            s1 <- checkStmt stmt1
            retInBranch1 <- gets retSet
            memory <- get
            modify (\st -> st { retSet = False })
            s2 <- checkStmt stmt2
            retInBranch2 <- gets retSet
            case retBefore of
                True -> do
                    modify (\st -> st { varEnv = varEnv memory, funEnv = funEnv memory, returnType = returnType memory, redefinedVars = redefinedVars memory, retSet = True })
                    return ()
                False -> case retInBranch1 == True && retInBranch2 == True of
                    False -> do
                        -- only 1 or neither branch has return, so it doesn't count
                        modify (\st -> st { retSet = False })
                        return ()
                        -- both have returns, so it always ends with return
                    True -> return ()
        _ -> throwError $ CompilerError { text = "Logical condition must be a boolean expression.", position = pos }

checkStmt (While pos (ELitTrue _) stmt) = checkStmt stmt

checkStmt (While pos cond stmt) = do
    condT <- checkExp cond
    retSetBefore <- gets retSet
    case condT of
        VBool -> do
            checkStmt stmt
            memory <- get
            modify (\st -> st {retSet = retSetBefore})
        _ -> throwError $ CompilerError { text = "Logical condition must be a boolean expression.", position = pos }

checkStmt (ForEach pos t (Ident x) (Ident a) stmt) = do
    memory <- get
    let itType = vTypeFromType t
    case Map.lookup a (varEnv memory) of
        Nothing -> throwError $ CompilerError { text = "Variable " ++ (show x) ++ " is not in the scope.", position = pos }
        Just (VArr vt) -> do
            case areSameType vt itType of
                False -> throwError $ CompilerError { text = "Could not match type " ++ (show itType) ++ " with expected " ++ (show vt) ++ ".", position = pos }
                True -> do
                    -- redefine the variable x for the scope of the next statement and say, that it has already been redefined
                    modify (\st -> st { varEnv = Map.insert x itType (varEnv memory), funEnv = funEnv memory, returnType = returnType memory, redefinedVars = Set.singleton x, retSet = retSet memory })
                    branchBlock stmt pos
                    --checkBlock b True
                    -- mark variable as no longer redefined
                    put (memory)
                    return ()

        _ -> throwError $ CompilerError { text = "Variable " ++ (show x) ++ " is not an array", position = pos}

checkStmt (BStmt _ b) = checkBlock b False

checkStmt (SPrintInt pos e) = do
    eType <- checkExp e
    matchType pos eType VInt

checkStmt (SPrintStr pos e) = do
    eType <- checkExp e
    matchType pos eType VStr

checkStmt (Error _) = return ()

checkStmt (SExp pos e) = checkExp e >> return ()

checkStmt (Ass pos (EVar pos2 x) eVal) = do
    varType <- checkExp (EVar pos2 x)
    valType <- checkExp eVal
    assertSameType pos valType varType
checkStmt (Ass pos (EVarArr pos2 e1 e2) eVal) = do
    varType <- checkExp (EVarArr pos2 e1 e2)
    valType <- checkExp eVal
    assertSameType pos valType varType
checkStmt (Ass pos (EAttr pos2 e (Ident id)) eVal) = do
    eType <- checkExp e 
    case eType of
        VArr vt -> throwError $ CompilerError { text = "Array atrributes cannot be set.", position = pos}
        _ -> do
            varType <- checkExp (EAttr pos2 e (Ident id))
            valType <- checkExp eVal
            assertSameType pos valType varType
checkStmt (Ass pos _ _) = throwError $ CompilerError { text = "Assignments can only be called on variables.", position = pos}

checkStmt (VRet pos) = do
    memory <- get
    case returnType memory of
        VVoid -> do
            modify (\st -> st { retSet = True })
            return ()
        retType -> throwError $ CompilerError { text = "Incorrect return type. Expected " ++ (show retType) ++ " but was given " ++ (show VVoid) ++ ".", position = pos}

checkStmt (Ret pos e) = do
    memory <- get
    eType <- checkExp e
    let retType = returnType memory
    case areSameType retType eType of
        True -> do
            modify (\st -> st {retSet = True})
            return ()
        False -> throwError $ CompilerError { text = "Incorrect return type. Expected " ++ (show retType) ++ " but was given " ++ (show eType) ++ ".", position = pos}

checkTypes :: Program -> Either CompilerError ()
checkTypes (Prog _ topDefs) = fst $ runState (runExceptT (checkAll topDefs)) emptyState
