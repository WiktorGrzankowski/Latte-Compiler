module Backend.ExpCompiler where

import Latte.AbsLatte
import Data.Map as Map
import Data.Text.Lazy.Builder
import Backend.Core
import Control.Monad.Except
import Control.Monad.State

isVarFunctionArg :: String -> [(String, Type)] -> Int -> Maybe (Int, Type)
isVarFunctionArg v [] _ = Nothing
isVarFunctionArg v ((x, t):xs) n = case v == x of
    True -> Just (n, t)
    False -> isVarFunctionArg v xs (n+1)

prepareArguments :: [Expr] -> [(String, Type)] -> Integer -> CM (Builder, Int)
prepareArguments [] _ _ = return (fromString "", 0)
prepareArguments (e:rest) ((_, t):otherArgs) argNr
    | argNr <= 6 = do
        -- eval e and save it to correct register
        (eCode, _) <- compExp e "rax"
        -- it's in rax - always, also for functions calls
        let move = movToRegFromReg (argRegister argNr (typeSize t)) (raxPartBytes (typeSize t))
        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        
        return (formatStrings [eCode, move, restCode], restSize)
    | argNr == 7 = do
        -- prepare stack
        let argsLeft = 1 + (length rest)
        -- let makeSpace = allocateStack (8 * (toInteger argsLeft))
        -- move first to stack
        (eCode, _) <- compExp e "rax"-- result in rax
        -- move result to stack
        let move = fromString $ "   mov [rsp + " ++ (show 0) ++ "], " ++ (raxPartBytes (typeSize t)) ++ "\n"        
        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        let makeSpace = allocateStack $ toInteger (restSize + (typeSize t))
        return (formatStrings [makeSpace, eCode, move, restCode], restSize + (typeSize t))
    | otherwise = do
        (eCode, _) <- compExp e "rax"
        let move = fromString $ "   mov [rsp + " ++ (show ((argNr - 7) * (toInteger (typeSize t)))) ++ "], " ++ (raxPartBytes (typeSize t)) ++ "\n"
        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        return (formatStrings [eCode, move, restCode], restSize + (typeSize t))



compExp :: Expr -> String -> CM (Builder, TType)
compExp (ELitInt _ i) reg = return (movToRegLiteralInt "rax" i, TInt)
compExp (ELitTrue _) reg = return (movToRegLiteralBool "al" 1, TBool)
compExp (ELitFalse _) reg = return (movToRegLiteralBool "al" 0, TBool)
compExp (EString _ s) reg = do
    strs <- gets hardcodedStrs
    -- check if this string already exists
    case Map.lookup s strs of
        Nothing -> do
            let strAddrRef = alloc strs
            modify (\st -> st {hardcodedStrs = Map.insert s strAddrRef strs })
            let code = fromString $ "   mov rax, " ++ strAddrRef ++ "\n"
            return (code, TStr)
        Just addr -> do
            let code = fromString $ "   mov rax, " ++ addr ++ "\n"
            return (code, TStr)

compExp (Neg _ e) reg = do
    (code, _) <- compExp e "rax"
    let negate = fromString "   neg rax\n"
    return (formatStrings [code, negate], TInt)
compExp (Not _ e) reg = do
    (code, _) <- compExp e "rax"
    -- score is in rax (al actually)
    let negate = fromString "   xor rax, 1\n"
    return (formatStrings [code, negate], TBool)

compExp (EVar _ (Ident x)) reg = do
    memory <- get
    case Map.lookup x (varEnv memory) of
        Just (loc, vt) -> do 
            let code = movToRegFromStack reg loc
            return (code, vt)
        Nothing -> do
            case isVarFunctionArg x (funArgs memory) 1 of
                Just (n, t) -> do
                    let code = fromString $ "   mov " ++ reg ++ ", [rbp + " ++ (show ((n-7)*(typeSize t) + 16)) ++ "]\n"
                    return (code, tTypeFromType t) 

compExp (SReadInt _) reg = do
    return (fromString "   call readInt\n", TInt)

compExp (SReadStr _) reg = do
    return (fromString "   call readString\n", TStr)

compExp (EApp pos (Ident f) exprs) reg = do
    funArgsBefore <- gets funArgs
    funs <- gets funEnv
    funsTypes <- gets funEnvTypes

    let args = Map.findWithDefault [] f funs
    (prepareCode, funArgsSize) <- prepareArguments exprs args 1

    let fCall = fromString $ "   call " ++ f ++ "\n"
    -- let stackCleanup = fromString $ "   add rsp, " ++ show ((max ((length exprs - 6) * 8) 0)) ++ "\n"
    let stackCleanup = fromString $ "   add rsp, " ++ (show funArgsSize) ++ "\n"
    -- modify (\st -> st {funArgs = funArgsBefore})
    case Map.lookup f funsTypes of
        Just vt -> return (formatStrings [prepareCode, fCall, stackCleanup], vt)

compExp (EArr _ t e) reg = do
    let arrayType = tTypeFromType t
    (code, vt) <- compExp e "rax" -- array size
    let movSizeToRdi = fromString "   mov rdi, rax\n"
    let movTypeSizeToRsi = fromString "   mov rsi, 8\n"
    let allocateSpace = fromString "   call allocateArray\n"

    case arrayType of
        TInt -> return (formatStrings [code, movSizeToRdi, movTypeSizeToRsi, allocateSpace], (TArr arrayType))
        TStr -> do
            let pushR12 = pushReg "r12"
            let popR12 = popReg "r12"
            let pushRax = pushReg "rax"
            let popRax = popReg "rax"
            let saveSizeToR12 = movToRegFromReg "r12" "rdi"
            let movSizeBackToRcx = movToRegFromReg "rcx" "r12"
            -- set all walues in "rax + 8 * (up to size)" to be s0
            let loopLabel = "init_loop"
            let loopEndLabel = "end_loop"
            let checkIfEmptyArr = fromString "   test rcx, rcx\n   jz end_loop\n"
            let movSizeBackToRdi = movToRegFromReg "rdi" "r12"
            let loopLabelStart = fromString $ loopLabel ++ ":\n"
            let loopEndLabelCode = fromString $ loopEndLabel ++ ":\n"
            let insideLoop = formatStrings [fromString "   mov qword [rax], s0\n", fromString "   add rax, 8\n", fromString "   loop init_loop\n"]

            let initAllocation = formatStrings [pushR12, code, movSizeToRdi, saveSizeToR12, movTypeSizeToRsi, allocateSpace]
            let initLoop = formatStrings [pushRax, movSizeBackToRcx, checkIfEmptyArr,loopLabelStart, insideLoop, loopEndLabelCode, popRax]
            return (formatStrings [initAllocation, initLoop, popR12], (TArr arrayType))

    -- now the pointer is in "rax"
    -- add mapping var_name -> allocated_addr

    -- return (formatStrings [code, movSizeToRdi, movTypeSizeToRsi, allocateSpace], (TArr arrayType))

compExp (EVarArr pos e eInd) reg = do
    (codeInd, _) <- compExp eInd "rax"
    let saveRax = pushReg "rax"
    (codeVar, vt) <- compExp e "rax"
    let moveVarToRdi = movToRegFromReg "rdi" "rax"
    let retrieveRax = popReg "rax"
    -- now under rdi is the index where we want to look at (times 8)
    -- we want result to be [rax + 8 * rdi]
    let getFromArr = fromString "   mov rax, [rdi + 8 * rax]\n"
    return (formatStrings [codeInd, saveRax, codeVar, moveVarToRdi, retrieveRax, getFromArr], vt)

compExp (EAdd _ e1 (Plus _) e2) reg = do
    (code1, vt1) <- compExp e1 "rax"
    let saveRax = pushReg "rax"
    (code2, vt2) <- compExp e2 "rax"
    let retrieveRax = popReg "rax"
    case areBothStrings vt1 vt2 of
        False -> do
            let movSecondResult = movToRegFromReg "rdx" "rax"
            return (formatStrings [code1, saveRax, code2, movSecondResult, retrieveRax, fromString "   add rax, rdx\n"], TInt)
        True -> do
            let movSecondResult = movToRegFromReg "rsi" "rax"
            let movFirstResult = movToRegFromReg "rdi" "rax"
            -- arguments are in rdi and rsi
            let concatCode = fromString "   call concat\n"
            -- result is in rax
            return (formatStrings [code1, saveRax, code2, movSecondResult, retrieveRax, movFirstResult, concatCode], TStr)
            -- concat strings

compExp (EAdd _ e1 (Minus _) e2) reg = do
    (code, _) <- compExp e1 "rax"
    let saveRdi = pushReg "rax"
    (code2, _) <- compExp e2 "rax" -- result is always in rdi
    let movSecondResult = movToRegFromReg "rdx" "rax"
    let retrieveRdi = popReg "rax"
    return (formatStrings [code, saveRdi, code2, movSecondResult, retrieveRdi, fromString "   sub rax, rdx\n"], TInt)

compExp (EMul _ e1 (Times _) e2) reg = do
    (code, _) <- compExp e1 "rax"
    -- store rdi to stack
    let saveRdi = pushReg "rax"
    (code2, _) <- compExp e2 "rax" -- result is always in rdi
    -- get result to another register
    let movSecondResult = movToRegFromReg "rdx" "rax"
    let retrieveRdi = popReg "rax"
    return (formatStrings [code, saveRdi, code2, movSecondResult, retrieveRdi, fromString "   imul rax, rdx\n"], TInt)

compExp (EMul _ e1 (Div _) e2) reg = do
    -- save first to rax
    (code, _) <- compExp e1 "rax"
    let saveRax = pushReg "rax"
    -- let moveRdiToRax = movToRegFromReg "rax" "rdi"
    -- save second to rcx
    (code2, _) <- compExp e2 "rax"
    -- mov it to rcx
    let movSecondResult = movToRegFromReg "rcx" "rax"
    let retrieveRax = popReg "rax"
    let cqoMagic = fromString "   cqo\n"
    let divide = fromString "   idiv rcx\n"
    -- score is in rax

    let xorUpperBits = fromString $ "   xor rdx, rdx\n"
    return (formatStrings [code, saveRax, code2, movSecondResult, xorUpperBits, retrieveRax, cqoMagic, divide], TInt)

compExp (EMul _ e1 (Mod _) e2) reg = do
    (code, _) <- compExp e1 "rax"
    let saveRax = pushReg "rax"
    (code2, _) <- compExp e2 "rax"
    let movSecondResult = movToRegFromReg "rcx" "rax"
    let retrieveRax = popReg "rax"
    let cqoMagic = fromString "   cqo\n"
    let divide = fromString "   idiv rcx\n"
    let movResultToRax = movToRegFromReg "rax"  "rdx"
    let xorUpperBits = fromString $ "   xor rdx, rdx\n"
    return (formatStrings [code, saveRax, code2, movSecondResult, xorUpperBits, retrieveRax, cqoMagic, divide, movResultToRax], TInt)

compExp (EOr _ e1 e2) reg= do
    (code, _) <- compExp e1 "rax"
    let checkFirst = fromString "   cmp al, 1\n"
    labelName <- gets labelId
    -- add label for else
    let finishLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let finishIfFirstTrue = fromString $ "   je " ++ finishLabel ++ "\n"
    let finishLabelCode = fromString $ finishLabel ++ ":\n"

    let saveRax = pushReg "rax"
    (code2, _) <- compExp e2 "rax"
    let movSecondResult = movToRegFromReg "rcx" "rax"
    let retrieveRax = popReg "rax"
    let or = fromString "   or rax, rcx\n"
    return (formatStrings [code, checkFirst, finishIfFirstTrue, saveRax, code2, movSecondResult, retrieveRax, or, finishLabelCode], TBool)

compExp (EAnd _ e1 e2) reg= do
    (code, _) <- compExp e1 "rax"
    let checkFirst = fromString "   cmp al, 0\n"
    labelName <- gets labelId
    -- add label for else
    let finishLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let finishIfFirstTrue = fromString $ "   je " ++ finishLabel ++ "\n"
    let finishLabelCode = fromString $ finishLabel ++ ":\n"

    let saveRax = pushReg "rax"
    (code2, _) <- compExp e2 "rax"
    let movSecondResult = movToRegFromReg "rcx" "rax"
    let retrieveRax = popReg "rax"
    let and = fromString "   and rax, rcx\n"
    return (formatStrings [code, checkFirst, finishIfFirstTrue, saveRax, code2, movSecondResult, retrieveRax, and, finishLabelCode], TBool)

compExp (ERel _ e1 relOp e2) reg = do
    (code, _) <- compExp e1 "rax"
    let movFirstResult = movToRegFromReg "rdx" "rax"
    let saveRdx = pushReg "rdx"
    (code2, _) <- compExp e2 "rax"
    let movSecondResult = movToRegFromReg "rcx" "rax"
    let retrieveRdx = popReg "rdx"
    let xorRax = fromString "   xor rax, rax\n"
    let compare = fromString "   cmp rdx, rcx\n"
    let setForRelOp = fromString $ getSet relOp 
    return (formatStrings [code, movFirstResult, saveRdx, code2, movSecondResult, retrieveRdx, xorRax, compare, setForRelOp], TBool)
    where
        getSet :: RelOp -> String
        getSet (LTH _) = "   setl al\n"
        getSet (GTH _) = "   setg al\n"
        getSet (GE _) = "   setge al\n"
        getSet (LE _) = "   setle al\n"
        getSet (EQU _) = "   sete al\n"
        getSet (NE _) = "   setne al\n"
         
