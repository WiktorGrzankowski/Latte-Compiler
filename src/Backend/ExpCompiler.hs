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

prepareArguments :: [Expr] -> [(String, Type)] -> Integer -> CM (Builder, Integer)
-- najpierw zapisac wszystkie rzeczy na stos
-- potem pierwsze 6 argumentow przepisac na rejestry
-- nastepnie, jesli sa jeszcze argumenty do wrzucenia na stos, dodać 40 do rsp
-- prepareArguments [] _ argNr = return (emptyCode, 0)
prepareArguments [] _ argNr
    | argNr == 1 = return (emptyCode, 0)
    | otherwise = do
        code <- getArgsBackFromStack 1 (argNr - 1)
        return (code, 0)
        -- return (code, toInteger ((argNr - 7) * 8))
        -- there are some arguments to be taken from the stack
    where
        getArgsBackFromStack :: Integer -> Integer -> CM Builder
        getArgsBackFromStack argNr lastArg
            | argNr > lastArg = return emptyCode
            -- move to rdi
            | argNr <= 6 = do
                let thisArgReg = argRegister argNr 8
                let move = fromString $ "   mov " ++ thisArgReg ++ ", [rsp + " ++ (show (8 * (argNr - 1))) ++ "]\n"
                restCode <- getArgsBackFromStack (argNr + 1) lastArg
                return $ formatStrings [move, restCode] -- todo the second part is stupid
            | argNr == 7 = do
                -- simply add 40 to the stack
                let fixStackOffset = allocateStack $ toInteger (-48)
                return fixStackOffset
 

prepareArguments (e:rest) ((_, t):otherArgs) argNr
    | argNr == 1 = do
        -- allocate the space already
        let makeSpace = allocateStack $ toInteger ((1 + (length otherArgs)) * 8)

        (eCode, _) <- compExp e 
        let moveToStack = fromString $ "   mov [rsp + " ++ (show ((argNr - 1) * 8)) ++ "], rax\n"
        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        let allArgsCnt = toInteger $ (length otherArgs) + 1
        let laterToAdd = if allArgsCnt > 6 then (8 * (allArgsCnt - 6)) else (8 * allArgsCnt)
        return (formatStrings [makeSpace, eCode, moveToStack, restCode], laterToAdd)
    | argNr <= 6 = do
        (eCode, _) <- compExp e 
        let moveToStack = fromString $ "   mov [rsp + " ++ (show ((argNr - 1) * 8)) ++ "], rax\n"
        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        return (formatStrings [eCode, moveToStack, restCode], restSize)
    -- | argNr == 7 = do
    --     let argsLeft = 1 + (length rest)
    --     (eCode, _) <- compExp e
    --     let move = fromString $ "   mov [rsp + " ++ (show ((argNr - 1) * 8)) ++ "], rax\n"
    --     (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)

    --     return (formatStrings [eCode, move, restCode], restSize + (typeSize t))
    | otherwise = do
        (eCode, _) <- compExp e 
        let move = fromString $ "   mov [rsp + " ++ (show ((argNr - 1) * 8)) ++ "], rax\n" 
        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        return (formatStrings [eCode, move, restCode], restSize + 8)





-- prepareArguments (e:rest) ((_, t):otherArgs) argNr
--     | argNr == 1 = do
--         (eCode, _) <- compExp e 
--         let move = movToRegFromReg (argRegister argNr (typeSize t)) (raxPartBytes (typeSize t))
--         (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
--         return (formatStrings [restCode, eCode, move], restSize)
--     | argNr <= 6 = do
--         (eCode, _) <- compExp e 
--         let move = movToRegFromReg (argRegister argNr (typeSize t)) (raxPartBytes (typeSize t))
--         (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
--         return (formatStrings [eCode, move, restCode], restSize)
--     | argNr == 7 = do
--         let argsLeft = 1 + (length rest)
--         (eCode, _) <- compExp e
--         let move = movToRegFromReg (regValAtOffset rspR (show 0)) (raxPartBytes (typeSize t))  
--         (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
--         let makeSpace = allocateStack $ toInteger (restSize + (typeSize t))
--         return (formatStrings [makeSpace, eCode, move, restCode], restSize + (typeSize t))
--     | otherwise = do
--         (eCode, _) <- compExp e 
--         let move = movToRegFromReg (regValAtOffset rspR (show ((argNr - 7) * (toInteger (typeSize t))))) (raxPartBytes (typeSize t))  
--         (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
--         return (formatStrings [eCode, move, restCode], restSize + (typeSize t))



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
    let negate = negReg raxR
    return (formatStrings [code, negate], TInt)
compExp (Not _ e) = do
    (code, _) <- compExp e
    let negate = xorCall alR (show 1)
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
                    let code = movToRegFromReg raxR (regValAtOffset rbpR (show ((n-7)*(typeSize t) + 16)))
                    return (code, tTypeFromType t)
                Nothing -> do
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty (currClass memory) (classEnv memory)
                    let (varOffset, varType) = Map.findWithDefault (0, TNull) x thisClassFields
                    let getInstanceArg = movToRegSelfArg raxR
                    let getClassVar = movToRegFromReg raxR (regValAtOffset raxR (show varOffset))
                    return (formatStrings [getInstanceArg, getClassVar], varType)

compExp (SReadInt _) = return (callFun "readInt", TInt)

compExp (SReadStr _) = return (callFun "readString", TStr)

compExp (EApp pos (Ident f) exprs) = do
    funArgsBefore <- gets funArgs
    funs <- gets funEnv
    funsTypes <- gets funEnvTypes

    let args = Map.findWithDefault [] f funs
    (prepareCode, funArgsSize) <- prepareArguments exprs args 1

    let fCall = callFun f
    let stackCleanup = addCall rspR (show funArgsSize)
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

    let fCall = callFun methodIdent
    let stackCleanup = addCall rspR (show funArgsSize)
    case Map.lookup methodIdent funsTypes of
        Just vt -> return (formatStrings [prepareCode, fCall, stackCleanup], vt)

compExp (EClass _ (Ident className)) = do
    memory <- get
    let classEnvs = classEnv memory
    let thisClassFields = Map.findWithDefault Map.empty className classEnvs
    let classSize = toInteger $ (Map.size thisClassFields) * 8 -- each field is 8 bytes long
    let movSizeToRdi = movToRegLiteralInt rdiR classSize
    let allocateSpace = callFun "allocateClass"
    let code = formatStrings [movSizeToRdi, allocateSpace]
    defVals <- mapM setFieldToDefaultValues (toList thisClassFields)
    return (formatStrings [code, formatStrings defVals], TClass className)
    where
        setFieldToDefaultValues :: (Var, (Integer, TType)) -> CM Builder
        setFieldToDefaultValues (x, (offset, TInt)) = do
            let pushR12 = pushReg r12R
            let movValToR12 = movToRegLiteralInt r12R 0
            let movR12ToPointer = movToRegFromReg (regValAtOffset raxR (show offset)) r12R
            let popR12 = popReg r12R
            return $ formatStrings [pushR12, movValToR12, movR12ToPointer, popR12]
        setFieldToDefaultValues (x, (offset, TBool)) = do
            let pushR12 = pushReg r12R
            let movValToR12 = movToRegLiteralBool r12R 0
            let movR12ToPointer = movToRegFromReg (regValAtOffset raxR (show offset)) r12R
            let popR12 = popReg r12R
            return $ formatStrings [pushR12, movValToR12, movR12ToPointer, popR12]
        setFieldToDefaultValues (x, (offset, TStr)) = do
            let pushR12 = pushReg r12R
            let movValToR12 = movToRegDefaultString r12R
            let movR12ToPointer = movToRegFromReg (regValAtOffset raxR (show offset)) r12R
            let popR12 = popReg r12R
            return $ formatStrings [pushR12, movValToR12, movR12ToPointer, popR12]
        setFieldToDefaultValues _ = return emptyCode

compExp (EArrClass pos (Ident className) e) = compExp (EArr pos (ClassT pos (Ident className)) e)

compExp (EArr pos t e) = do
    let arrayType = tTypeFromType t
    let pushR12 = pushReg r12R
    (code, vt) <- compExp e
    let movSizeToRdi = movToRegFromReg rdiR raxR
    let movTypeSizeToRsi = movToRegLiteralInt rsiR 8
    let saveSizeToR12 = movToRegFromReg r12R rdiR
    let accountForLengthAttr = addCall rdiR (show 1)-- first we store 8 bytes for length ad
    let allocateSpace = callFun "allocateArray"
    let setFirstPlaceToLen = movToRegFromReg (regValAtOffset raxR (show 0)) r12R
    let popR12 = popReg r12R

    case arrayType of
        TStr -> do
            labelNr <- gets labelId
            let pushRax = pushReg raxR
            let popRax = popReg raxR
            let saveSizeToR12 = movToRegFromReg r12R rdiR
            let movSizeBackToRcx = movToRegFromReg rcxR r12R
            let loopLabel = "init_loop" ++ show (labelNr)
            let loopEndLabel = "end_loop" ++ show (labelNr)
            let checkIfEmptyArr = fromString $ "   test rcx, rcx\n   jz " ++ loopEndLabel ++ "\n"
            let loopLabelStart = labelToCode loopLabel
            let loopEndLabelCode = labelToCode loopEndLabel
            let insideLoop = formatStrings [fromString "   mov qword [rax + 8], s0\n", addCall raxR (show 8), fromString $ "   loop " ++ loopLabel ++ "\n"]
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
                TArr _ -> return (formatStrings [codeExp, movToRegFromReg raxR (regValAtOffset raxR (show 0))], TInt)
        _ -> do
            case eType of
                (TClass className) -> do
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty className (classEnv memory)
                    let (offset, fieldType) = Map.findWithDefault (0, TNull) field thisClassFields
                    let getValue = movToRegFromReg raxR (regValAtOffset raxR (show offset))
                    return (formatStrings [codeExp, getValue], fieldType)
                (TArr (TClass className)) -> do
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty className (classEnv memory)
                    let (offset, fieldType) = Map.findWithDefault (0, TNull) field thisClassFields
                    let getValue = movToRegFromReg raxR (regValAtOffset raxR (show offset))
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
            return (formatStrings [code1, saveRax, code2, movSecondResult, retrieveRax, addCall raxR rdxR], TInt)
        True -> do
            let movSecondResult = movToRegFromReg rsiR raxR
            let movFirstResult = movToRegFromReg rdiR raxR
            let concatCode = callFun "concat"
            return (formatStrings [code1, saveRax, code2, movSecondResult, retrieveRax, movFirstResult, concatCode], TStr)

compExp (EAdd _ e1 (Minus _) e2) = do
    (code, _) <- compExp e1 
    let saveRdi = pushReg raxR
    (code2, _) <- compExp e2
    let movSecondResult = movToRegFromReg rdxR raxR
    let retrieveRdi = popReg raxR
    return (formatStrings [code, saveRdi, code2, movSecondResult, retrieveRdi, subCall raxR rdxR], TInt)

compExp (EMul _ e1 (Times _) e2) = do
    (code, _) <- compExp e1 
    let saveRdi = pushReg raxR
    (code2, _) <- compExp e2 
    let movSecondResult = movToRegFromReg rdxR raxR
    let retrieveRdi = popReg raxR
    return (formatStrings [code, saveRdi, code2, movSecondResult, retrieveRdi, mulCall raxR rdxR], TInt)

compExp (EMul _ e1 (Div _) e2) = do
    (code, _) <- compExp e1 
    let saveRax = pushReg raxR
    (code2, _) <- compExp e2 
    let movSecondResult = movToRegFromReg rcxR raxR
    let retrieveRax = popReg raxR
    let cqoMagic = cqoCall
    let divide = divideReg rcxR
    let xorUpperBits = xorCall rdxR rdxR
    return (formatStrings [code, saveRax, code2, movSecondResult, xorUpperBits, retrieveRax, cqoMagic, divide], TInt)

compExp (EMul _ e1 (Mod _) e2) = do
    (code, _) <- compExp e1
    let saveRax = pushReg raxR
    (code2, _) <- compExp e2 
    let movSecondResult = movToRegFromReg rcxR raxR
    let retrieveRax = popReg raxR
    let cqoMagic = cqoCall
    let divide = divideReg rcxR
    let movResultToRax = movToRegFromReg raxR  rdxR
    let xorUpperBits = xorCall rdxR rdxR
    return (formatStrings [code, saveRax, code2, movSecondResult, xorUpperBits, retrieveRax, cqoMagic, divide, movResultToRax], TInt)

compExp (EOr _ e1 e2) = do
    (code, _) <- compExp e1 
    let checkFirst = compareCall alR (show 1)
    labelName <- gets labelId
    let finishLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let finishIfFirstTrue = jeTo finishLabel
    let finishLabelCode = labelToCode finishLabel
    let saveRax = pushReg raxR
    (code2, _) <- compExp e2
    let movSecondResult = movToRegFromReg rcxR raxR
    let retrieveRax = popReg raxR
    let or = orRegs raxR rcxR
    return (formatStrings [code, checkFirst, finishIfFirstTrue, saveRax, code2, movSecondResult, retrieveRax, or, finishLabelCode], TBool)

compExp (EAnd _ e1 e2) = do
    (code, _) <- compExp e1
    let checkFirst = compareCall alR (show 0)
    labelName <- gets labelId
    let finishLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let finishIfFirstTrue = jeTo finishLabel
    let finishLabelCode = labelToCode finishLabel
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
    let xorRax = xorCall raxR raxR
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