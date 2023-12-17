module Frontend.ItemsChecker where
    
import Frontend.Core
import Frontend.ExpChecker (checkExp)

import Data.Map as Map
import Control.Monad.Except
import Control.Monad.State
import Data.Map as Map
import Data.Set as Set
import Latte.AbsLatte
import Latte.ErrM
import Latte.SkelLatte
import Latte.PrintLatte

checkItems :: Type -> [Item] -> TypeCheckerMonad ()
checkItems t [] = return ()
checkItems t ((NoInit pos (Ident x)) : rest) = do
    memory <- get
    case Map.lookup x (varEnv memory) of
        Nothing -> do     
            modify (\st -> st { varEnv = Map.insert x (vTypeFromType t) (varEnv memory), funEnv = funEnv memory, returnType = returnType memory, redefinedVars = Set.insert x (redefinedVars memory), retSet = retSet memory  })
            checkItems t rest
        _ -> case Set.member x (redefinedVars memory) of
            True -> throwError $ CompilerError { text = "Variable " ++ (show x) ++ " is already defined in this scope.", position = pos}
            False -> do
                modify (\st -> st { varEnv = Map.insert x (vTypeFromType t) (varEnv memory), funEnv = funEnv memory, returnType = returnType memory, redefinedVars = Set.insert x (redefinedVars memory), retSet = retSet memory })
                checkItems t rest

checkItems t ((Init pos (Ident x) e) : rest) = do
    expType <- checkExp e 
    let vt = vTypeFromType t
    case areSameType vt expType of
        True -> do
            memory <- get
            case Map.lookup x (varEnv memory) of
                Nothing -> do
                    modify (\st -> st { varEnv = Map.insert x (vTypeFromType t) (varEnv memory), funEnv = funEnv memory, returnType = returnType memory, redefinedVars = Set.insert x (redefinedVars memory), retSet = retSet memory })
                    checkItems t rest
                _ -> case Set.member x (redefinedVars memory) of
                    True -> throwError $ CompilerError { text = "Variable " ++ (show x) ++ " is already defined in this scope.", position = pos}
                    False -> do
                        modify (\st -> st { varEnv = Map.insert x (vTypeFromType t) (varEnv memory), funEnv = funEnv memory, returnType = returnType memory, redefinedVars = Set.insert x (redefinedVars memory), retSet = retSet memory })
                        checkItems t rest
        False -> throwError $ CompilerError { text = "Could not match type " ++ (show expType) ++ " with variable of type " ++ (show vt) ++ ".", position = pos}
