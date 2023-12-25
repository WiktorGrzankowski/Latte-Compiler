module Frontend.ExpChecker where

import Frontend.Core

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

checkExp :: Expr -> TypeCheckerMonad VType
checkExp (ELitInt _ _) = return VInt
checkExp (EString _ _) = return VStr 
checkExp (ELitTrue _) = return VBool
checkExp (ELitFalse _) = return VBool
checkExp (ENull _) = return VNull
checkExp (ESelf pos) = do
    className <- gets currClass
    case className of
        "(null)" -> throwError $ CompilerError { text = "Usage of .self is not allowed outside of class methods.", position = pos}
        _ -> return $ VClass className

checkExp (Not pos e) = do
    t <- checkExp e
    case t of
        VBool -> return VBool
        _ -> throwError $ CompilerError { text = "Type mismatch! Negation (not) is only allowed for booleans", position = pos}

checkExp (Neg pos e) = do
    t <- checkExp e
    case t of
        VInt-> return VInt
        _ -> throwError $ CompilerError { text = "Type mismatch! Negation (-) is only allowed for integers", position = pos}

checkExp (EAnd pos e1 e2) = do
    t1 <- checkExp e1
    t2 <- checkExp e2
    case getCommonType t1 t2 of
        Just VBool -> return VBool
        Nothing -> throwError $ CompilerError { text = "Type mismatch! Concjunction is allowed only for booleans.", position = pos}  

checkExp (EOr pos e1 e2) = do
    t1 <- checkExp e1
    t2 <- checkExp e2
    case getCommonType t1 t2 of
        Just VBool -> return VBool
        Nothing -> throwError $ CompilerError { text = "Type mismatch! Disjunction is allowed only for booleans.", position = pos}  

checkExp (EVar pos (Ident x)) = do
    memory <- get
    case Map.lookup x (varEnv memory) of
        Just t -> return t
        Nothing -> do
            -- look in superclasses
            maybeFromSuper <-  getVarFromSuperclass x (currClass memory)
            case maybeFromSuper of
                Nothing -> throwError $ CompilerError { text = "Variable " ++ (show x) ++ " is not in the scope.", position = pos}
                Just vt -> return vt
-- checkExp (EVar pos (Ident x)) = do
--     memory <- get
--     case Map.lookup x (varEnv memory) of
--         Nothing -> throwError $ CompilerError { text = "Variable " ++ (show x) ++ " is not in the scope.", position = pos}
--         Just t -> return t

checkExp (EVarArr pos e eInd) = do
    eType <- checkExp e 
    eIndType <- checkExp eInd
    assertInt pos eIndType
    case eType of
        VArr vt -> return vt
        other -> throwError $ CompilerError { text = "Type mismatch! Expected array but got " ++ (show other) ++ ".", position = pos}

checkExp (ERel pos e1 op e2) = do
    t1 <- checkExp e1
    t2 <- checkExp e2
    case getCommonType t1 t2 of
        Just VInt -> return VBool
        Just vt -> if isEqOp op 
            then 
                return VBool 
            else 
                throwError $ CompilerError { text = "Type mismatch! Comparison operations (>, >=, <, <=) are allowed only for integers.", position = pos} 
        Nothing -> throwError $ CompilerError { text = "Type mismatch! Comparison is allowed only between values of the same type.", position = pos} 

    where
        isEqOp :: RelOp -> Bool
        isEqOp (EQU _) = True
        isEqOp (NE _) = True
        isEqOp _ = False


checkExp (EAdd pos e1 op e2) = do
    t1 <- checkExp e1
    t2 <- checkExp e2
    case getCommonType t1 t2 of
        Just VStr -> case op of
            (Plus _) -> return VStr
            _ -> throwError $ CompilerError { text = "Type mismatch! Subtraction is allowed only for integers.", position = pos }
        Just VInt -> return VInt
        Nothing -> throwError $ CompilerError { text = "Type mismatch! Addition is allowed only for integers and strings.", position = pos }  


checkExp (EMul pos e1 op e2) = do
    t1 <- checkExp e1
    t2 <- checkExp e2
    case getCommonType t1 t2 of
        Just VInt -> return VInt
        _ -> throwError $ CompilerError { text = "Type mismatch! Multiplication and division is allowed only for integers.", position = pos }

checkExp (SReadInt _) = return VInt

checkExp (SReadStr _) = return VStr

checkExp (EArr pos t e) = do
    eType <- checkExp e 
    case eType of
        VInt -> return $ (VArr $ vTypeFromType t)
        vt -> throwError $ CompilerError { text = "Type mismatch! Cannot match type " ++ (show vt) ++ " with expected " ++ (show VInt), position = pos }

checkExp (EArrClass pos (Ident x) e) = do
    eType <- checkExp e
    assertInt pos eType
    memory <- get
    case Map.lookup x (classEnv memory) of
        Just _ -> return $ VArr $ VClass x
        Nothing -> throwError $ CompilerError { text = "Class " ++ (show x) ++ " is not defined in this scope.", position = pos }

checkExp (EClass _ (Ident className)) = return $ VClass className

checkExp (EAttr pos e (Ident field)) = 
    case field of
        "length" -> do
            eType <- checkExp e 
            case eType of
                (VArr _) -> checkArrSize pos e
                _ -> checkClassElem pos e field
        _ -> checkClassElem pos e field

checkExp (EMethod pos e (Ident f) exprs) = do
    memory <- get
    eType <- checkExp e
    case eType of
        VClass className -> do
            let classMethods = Map.lookup className (classFunEnv memory)
            case classMethods of
                Just methodEnv -> do
                    case Map.lookup f methodEnv of
                        Just (FunT {funType = fType}) -> return fType
                        Nothing -> throwError $ CompilerError { text = "Type " ++ (show (VClass className)) ++ " does not have method " ++ (show f) ++ ".", position = pos }
                Nothing -> throwError $ CompilerError { text = "Class " ++ (show className) ++ " is not defined in this scope.", position = pos }
                
        other -> throwError $ CompilerError { text = "Type mismatch! Methods cannot be called for type " ++ (show other) ++ ".", position = pos }

checkExp (EApp pos (Ident f) exprs) = do
    memory <- get
    case f of
        "main" -> throwError $ CompilerError { text = "Function main() is not callable.", position = pos }
        _ -> do 
            let fun = Map.lookup f (funEnv memory)
            case fun of
                Just val -> do
                    argsMatch <- checkFunctionArgs (argTypes val) (reverse exprs)
                    case argsMatch of
                        True -> return (funType val)
                        False -> throwError $ CompilerError { text = "Function " ++ (show f) ++ " called with incorrect arguments.", position = pos}
                _ -> throwError $ CompilerError { text = "Function " ++ (show f) ++ " is not in the scope.", position = pos}

checkArrSize :: Pos -> Expr -> TypeCheckerMonad VType
checkArrSize pos e = do
    eType <- checkExp e 
    case eType of
        VArr _ -> return VInt
        other -> throwError $ CompilerError { text = "Type mismatch! Expected array but got " ++ (show other) ++ ".", position = pos}

checkClassElem :: Pos -> Expr -> Var -> TypeCheckerMonad VType
checkClassElem pos e field = do
    eType <- checkExp e 
    go pos eType field where
        go :: Pos -> VType -> Var -> TypeCheckerMonad VType
        go pos (VClass className) field = do
            memory <- get
            case Map.lookup className (classEnv memory) of
                Just env -> case Map.lookup field env of
                    Just attrType -> return attrType
                    Nothing -> throwError $ CompilerError { text = "Class " ++ (show className) ++ " does not have field " ++ (show field) ++ ".", position = pos}
        go pos vt field = throwError $ CompilerError { text = "Type mismatch! Expected class but got " ++ (show vt) ++ ".", position = pos}


checkFunctionArgs :: [VType] -> [Expr] -> TypeCheckerMonad Bool
checkFunctionArgs [] [] = return True
checkFunctionArgs [] exprs = return False
checkFunctionArgs args [] = return False
checkFunctionArgs (argType:rest) (expr:other) = do 
    expType <- checkExp expr
    case areSameType argType expType of
        True -> checkFunctionArgs rest other
        False -> return False