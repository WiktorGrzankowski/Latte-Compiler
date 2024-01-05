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
prepareArguments [] _ argNr 
    | argNr == 1 = return (fromString "", 0)
    | otherwise = return (popReg rdiR, 0)

prepareArguments (e:rest) ((_, t):otherArgs) argNr
    | argNr == 1 = do
        (eCode, _) <- compExp e 
        let move = movToRegFromReg (argRegister argNr (typeSize t)) (raxPartBytes (typeSize t))
        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        return (formatStrings [eCode, move, pushReg rdiR, restCode], restSize)
    | argNr <= 6 = do
        (eCode, _) <- compExp e 
        let move = movToRegFromReg (argRegister argNr (typeSize t)) (raxPartBytes (typeSize t))
        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        return (formatStrings [eCode, move, restCode], restSize)
    | argNr == 7 = do
        let argsLeft = 1 + (length rest)
        (eCode, _) <- compExp e
        let move = fromString $ "   mov [rsp + " ++ (show 0) ++ "], " ++ (raxPartBytes (typeSize t)) ++ "\n"        
        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        let makeSpace = allocateStack $ toInteger (restSize + (typeSize t))
        return (formatStrings [makeSpace, eCode, move, restCode], restSize + (typeSize t))
    | otherwise = do
        (eCode, _) <- compExp e 
        let move = fromString $ "   mov [rsp + " ++ (show ((argNr - 7) * (toInteger (typeSize t)))) ++ "], " ++ (raxPartBytes (typeSize t)) ++ "\n"
        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        return (formatStrings [eCode, move, restCode], restSize + (typeSize t))



compExp :: Expr -> CM (Builder, TType)
compExp (ENull _) = return (movToRegLiteralInt raxR 0, TNull)
compExp (ESelf _) = do
    className <- gets currClass
    return (movToRegSelfArg raxR, TClass className)
compExp (ELitInt _ i) = return (movToRegLiteralInt raxR i, TInt)
compExp (ELitTrue _) = return (movToRegLiteralBool alR 1, TBool)
compExp (ELitFalse _) = return (movToRegLiteralBool alR 0, TBool)
compExp (EString _ s) = do
    strs <- gets hardcodedStrs
    case Map.lookup s strs of
        Nothing -> do
            let strAddrRef = alloc strs
            modify (\st -> st {hardcodedStrs = Map.insert s strAddrRef strs })
            let code = movToRegString raxR strAddrRef
            return (code, TStr)
        Just addr -> do
            let code = movToRegString raxR addr
            return (code, TStr)

compExp (Neg _ e) = do
    (code, _) <- compExp e
    let negate = fromString "   neg rax\n"
    return (formatStrings [code, negate], TInt)
compExp (Not _ e) = do
    (code, _) <- compExp e
    let negate = fromString "   xor al, 1\n"
    return (formatStrings [code, negate], TBool)

compExp (EVar _ (Ident x)) = do
    memory <- get
    case Map.lookup x (varEnv memory) of
        Just (loc, vt) -> do 
            let code = movToRegFromStack raxR loc
            return (code, vt)
        Nothing -> do
            case isVarFunctionArg x (funArgs memory) 1 of
                Just (n, t) -> do
                    let code = fromString $ "   mov " ++ raxR ++ ", [rbp + " ++ (show ((n-7)*(typeSize t) + 16)) ++ "]\n"
                    return (code, tTypeFromType t)
                Nothing -> do
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty (currClass memory) (classEnv memory)
                    let (varOffset, varType) = Map.findWithDefault (0, TNull) x thisClassFields
                    let getInstanceArg = movToRegSelfArg raxR
                    let getClassVar = fromString $ "   mov rax, [rax + " ++ (show varOffset) ++ "]\n" 
                    return (formatStrings [getInstanceArg, getClassVar], varType)

compExp (SReadInt _) = return (fromString "   call readInt\n", TInt)

compExp (SReadStr _) = return (fromString "   call readString\n", TStr)

compExp (EApp pos (Ident f) exprs) = do
    funArgsBefore <- gets funArgs
    funs <- gets funEnv
    funsTypes <- gets funEnvTypes

    let args = Map.findWithDefault [] f funs
    (prepareCode, funArgsSize) <- prepareArguments exprs args 1

    let fCall = fromString $ "   call " ++ f ++ "\n"
    let stackCleanup = fromString $ "   add rsp, " ++ (show funArgsSize) ++ "\n"
    case Map.lookup f funsTypes of
        Just vt -> return (formatStrings [prepareCode, fCall, stackCleanup], vt)

compExp (EMethod pos e (Ident f) exprs) = do
    (codeGetClass, (TClass className)) <- compExp e
    allSuperclasses <- gets classSuperclasses
    methodIdent <- getMethodIdentInSuperclassses className f (className:(Map.findWithDefault [] className allSuperclasses))
    let actualExprs = (e:exprs)
    funArgsBefore <- gets funArgs
    funs <- gets classFunEnv
    funsTypes <- gets funEnvTypes

    args <- getArgsFromSuperclassMethods className f
    let actualArgs = (("self", (ClassT pos (Ident className))):args)
    (prepareCode, funArgsSize) <- prepareArguments actualExprs actualArgs 1

    let fCall = fromString $ "   call " ++ methodIdent ++ "\n"
    let stackCleanup = fromString $ "   add rsp, " ++ (show funArgsSize) ++ "\n"
    case Map.lookup methodIdent funsTypes of
        Just vt -> return (formatStrings [prepareCode, fCall, stackCleanup], vt)

compExp (EClass _ (Ident className)) = do
    memory <- get
    let classEnvs = classEnv memory
    let thisClassFields = Map.findWithDefault Map.empty className classEnvs
    let classSize = toInteger $ (Map.size thisClassFields) * 8 -- each field is 8 bytes long
    let movSizeToRdi = movToRegLiteralInt rdiR classSize
    let allocateSpace = fromString "   call allocateClass\n"
    let code = formatStrings [movSizeToRdi, allocateSpace]
    defVals <- mapM setFieldToDefaultValues (toList thisClassFields)
    return (formatStrings [code, formatStrings defVals], TClass className)
    where
        setFieldToDefaultValues :: (Var, (Integer, TType)) -> CM Builder
        setFieldToDefaultValues (x, (offset, TInt)) = do
            let pushR12 = pushReg r12R
            let movValToR12 = movToRegLiteralInt r12R 0
            let movR12ToPointer = fromString $ "   mov [rax + " ++ (show offset) ++ "], r12\n"
            let popR12 = popReg r12R
            return $ formatStrings [pushR12, movValToR12, movR12ToPointer, popR12]
        setFieldToDefaultValues (x, (offset, TBool)) = do
            let pushR12 = pushReg r12R
            let movValToR12 = movToRegLiteralBool r12R 0
            let movR12ToPointer = fromString $ "   mov [rax + " ++ (show offset) ++ "], r12\n"
            let popR12 = popReg r12R
            return $ formatStrings [pushR12, movValToR12, movR12ToPointer, popR12]
        setFieldToDefaultValues (x, (offset, TStr)) = do
            let pushR12 = pushReg r12R
            let movValToR12 = fromString "   mov r12, s0\n"
            let movR12ToPointer = fromString $ "   mov [rax + " ++ (show offset) ++ "], r12\n"
            let popR12 = popReg r12R
            return $ formatStrings [pushR12, movValToR12, movR12ToPointer, popR12]
        setFieldToDefaultValues _ = return $ fromString ""

compExp (EArrClass pos (Ident className) e) = compExp (EArr pos (ClassT pos (Ident className)) e)

compExp (EArr pos t e) = do
    let arrayType = tTypeFromType t
    let pushR12 = pushReg r12R
    (code, vt) <- compExp e
    let movSizeToRdi = fromString "   mov rdi, rax\n"
    let movTypeSizeToRsi = fromString "   mov rsi, 8\n"
    let saveSizeToR12 = movToRegFromReg r12R rdiR
    let accountForLengthAttr = fromString "   add rdi, 1\n" -- first we store 8 bytes for length
    let allocateSpace = fromString "   call allocateArray\n"
    let setFirstPlaceToLen = fromString "   mov [rax], r12\n"
    let popR12 = popReg r12R

    case arrayType of
        TStr -> do
            labelNr <- gets labelId
            let pushRax = pushReg raxR
            let popRax = popReg raxR
            let saveSizeToR12 = movToRegFromReg r12R rdiR
            let movSizeBackToRcx = movToRegFromReg rcxR r12R
            -- set all values in "rax + 8 * (up to size)" to be s0
            let loopLabel = "init_loop" ++ show (labelNr)
            let loopEndLabel = "end_loop" ++ show (labelNr)
            let checkIfEmptyArr = fromString $ "   test rcx, rcx\n   jz " ++ loopEndLabel ++ "\n"
            let loopLabelStart = fromString $ loopLabel ++ ":\n"
            let loopEndLabelCode = fromString $ loopEndLabel ++ ":\n"
            let insideLoop = formatStrings [fromString "   mov qword [rax + 8], s0\n", fromString "   add rax, 8\n", fromString $ "   loop " ++ loopLabel ++ "\n"]
            modify (\st -> st {labelId = labelNr + 1})
            let initAllocation = formatStrings [pushR12, code, movSizeToRdi, saveSizeToR12, movTypeSizeToRsi, accountForLengthAttr, allocateSpace, setFirstPlaceToLen]
            let initLoop = formatStrings [pushRax, movSizeBackToRcx, checkIfEmptyArr,loopLabelStart, insideLoop, loopEndLabelCode, popRax, popR12]
            return (formatStrings [initAllocation, initLoop], (TArr arrayType))
        _ -> do
            let baseCode = formatStrings [pushR12, code, movSizeToRdi, saveSizeToR12, movTypeSizeToRsi, accountForLengthAttr, allocateSpace, setFirstPlaceToLen, popR12]
            return (baseCode, (TArr arrayType))

compExp (EAttr pos e (Ident field)) = do
    (codeExp, eType) <- compExp e
    case field of
        "length" -> do
            case eType of
                TArr _ -> return (formatStrings [codeExp, fromString "   mov rax, [rax]\n"], TInt)
        _ -> do
            case eType of
                (TClass className) -> do
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty className (classEnv memory)
                    let (offset, fieldType) = Map.findWithDefault (0, TNull) field thisClassFields
                    let getValue = fromString $ "   mov rax, [rax + " ++ (show offset) ++ "]\n"
                    return (formatStrings [codeExp, getValue], fieldType)
                (TArr (TClass className)) -> do
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty className (classEnv memory)
                    let (offset, fieldType) = Map.findWithDefault (0, TNull) field thisClassFields
                    let getValue = fromString $ "   mov rax, [rax + " ++ (show offset) ++ "]\n"
                    return (formatStrings [codeExp, getValue], fieldType)  

compExp (EVarArr pos e eInd) = do
    (codeInd, _) <- compExp eInd 
    let saveRax = pushReg raxR
    (codeVar, vt) <- compExp e 
    let moveVarToRdi = movToRegFromReg rdiR raxR
    let retrieveRax = popReg raxR
    let getFromArr = fromString "   mov rax, [rdi + 8 + 8 * rax]\n"
    return (formatStrings [codeInd, saveRax, codeVar, moveVarToRdi, retrieveRax, getFromArr], vt)

compExp (EAdd _ e1 (Plus _) e2) = do
    (code1, vt1) <- compExp e1 
    let saveRax = pushReg raxR
    (code2, vt2) <- compExp e2
    let retrieveRax = popReg raxR
    case areBothStrings vt1 vt2 of
        False -> do
            let movSecondResult = movToRegFromReg rdxR raxR
            return (formatStrings [code1, saveRax, code2, movSecondResult, retrieveRax, fromString "   add rax, rdx\n"], TInt)
        True -> do
            let movSecondResult = movToRegFromReg "rsi" raxR
            let movFirstResult = movToRegFromReg rdiR raxR
            let concatCode = fromString "   call concat\n"
            return (formatStrings [code1, saveRax, code2, movSecondResult, retrieveRax, movFirstResult, concatCode], TStr)

compExp (EAdd _ e1 (Minus _) e2) = do
    (code, _) <- compExp e1 
    let saveRdi = pushReg raxR
    (code2, _) <- compExp e2
    let movSecondResult = movToRegFromReg rdxR raxR
    let retrieveRdi = popReg raxR
    return (formatStrings [code, saveRdi, code2, movSecondResult, retrieveRdi, fromString "   sub rax, rdx\n"], TInt)

compExp (EMul _ e1 (Times _) e2) = do
    (code, _) <- compExp e1 
    let saveRdi = pushReg raxR
    (code2, _) <- compExp e2 
    let movSecondResult = movToRegFromReg rdxR raxR
    let retrieveRdi = popReg raxR
    return (formatStrings [code, saveRdi, code2, movSecondResult, retrieveRdi, fromString "   imul rax, rdx\n"], TInt)

compExp (EMul _ e1 (Div _) e2) = do
    (code, _) <- compExp e1 
    let saveRax = pushReg raxR
    (code2, _) <- compExp e2 
    let movSecondResult = movToRegFromReg rcxR raxR
    let retrieveRax = popReg raxR
    let cqoMagic = fromString "   cqo\n"
    let divide = divideReg rcxR
    let xorUpperBits = xorRegs rdxR rdxR
    return (formatStrings [code, saveRax, code2, movSecondResult, xorUpperBits, retrieveRax, cqoMagic, divide], TInt)

compExp (EMul _ e1 (Mod _) e2) = do
    (code, _) <- compExp e1
    let saveRax = pushReg raxR
    (code2, _) <- compExp e2 
    let movSecondResult = movToRegFromReg rcxR raxR
    let retrieveRax = popReg raxR
    let cqoMagic = fromString "   cqo\n"
    let divide = divideReg rcxR
    let movResultToRax = movToRegFromReg raxR  rdxR
    let xorUpperBits = xorRegs rdxR rdxR
    return (formatStrings [code, saveRax, code2, movSecondResult, xorUpperBits, retrieveRax, cqoMagic, divide, movResultToRax], TInt)

compExp (EOr _ e1 e2) = do
    (code, _) <- compExp e1 
    let checkFirst = compareCall alR (show 1)
    labelName <- gets labelId
    let finishLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let finishIfFirstTrue = fromString $ "   je " ++ finishLabel ++ "\n"
    let finishLabelCode = fromString $ finishLabel ++ ":\n"
    let saveRax = pushReg raxR
    (code2, _) <- compExp e2
    let movSecondResult = movToRegFromReg rcxR raxR
    let retrieveRax = popReg raxR
    let or = fromString "   or rax, rcx\n"
    return (formatStrings [code, checkFirst, finishIfFirstTrue, saveRax, code2, movSecondResult, retrieveRax, or, finishLabelCode], TBool)

compExp (EAnd _ e1 e2) = do
    (code, _) <- compExp e1
    let checkFirst = compareCall alR (show 0)
    labelName <- gets labelId
    let finishLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let finishIfFirstTrue = fromString $ "   je " ++ finishLabel ++ "\n"
    let finishLabelCode = fromString $ finishLabel ++ ":\n"
    let saveRax = pushReg raxR
    (code2, _) <- compExp e2
    let movSecondResult = movToRegFromReg rcxR raxR
    let retrieveRax = popReg raxR
    let and = andRegs raxR rcxR
    return (formatStrings [code, checkFirst, finishIfFirstTrue, saveRax, code2, movSecondResult, retrieveRax, and, finishLabelCode], TBool)

compExp (ERel _ e1 relOp e2) = do
    (code, _) <- compExp e1
    let movFirstResult = movToRegFromReg rdxR raxR
    let saveRdx = pushReg rdxR
    (code2, _) <- compExp e2 
    let movSecondResult = movToRegFromReg rcxR raxR
    let retrieveRdx = popReg rdxR
    let xorRax = xorRegs raxR raxR
    let compare = compareCall rdxR rcxR
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