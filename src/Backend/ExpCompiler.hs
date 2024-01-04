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
-- prepareArguments [] _ _ = return (fromString "", 0)
prepareArguments [] _ argNr 
    | argNr == 1 = return (fromString "", 0)
    | otherwise = return (popReg "rdi", 0)

prepareArguments (e:rest) ((_, t):otherArgs) argNr
    | argNr == 1 = do
        -- all the same, but push rdi to save it
        -- eval e and save it to correct register
        (eCode, _) <- compExp e 
        -- it's in rax - always, also for functions calls
        let move = movToRegFromReg (argRegister argNr (typeSize t)) (raxPartBytes (typeSize t))

        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        return (formatStrings [eCode, move, pushReg "rdi", restCode], restSize)
    | argNr <= 6 = do
        -- eval e and save it to correct register
        (eCode, _) <- compExp e 
        -- it's in rax - always, also for functions calls
        let move = movToRegFromReg (argRegister argNr (typeSize t)) (raxPartBytes (typeSize t))

        (restCode, restSize) <- prepareArguments rest otherArgs (argNr + 1)
        return (formatStrings [eCode, move, restCode], restSize)
    | argNr == 7 = do
        -- prepare stack
        let argsLeft = 1 + (length rest)
        -- let makeSpace = allocateStack (8 * (toInteger argsLeft))
        -- move first to stack
        (eCode, _) <- compExp e
        -- move result to stack
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
compExp (ENull _) = return (movToRegLiteralInt "rax" 0, TNull)
compExp (ESelf _) = do
    className <- gets currClass
    return (fromString "   mov rax, [rbp - 8]\n", TClass className)
compExp (ELitInt _ i) = return (movToRegLiteralInt "rax" i, TInt)
compExp (ELitTrue _) = return (movToRegLiteralBool "al" 1, TBool)
compExp (ELitFalse _) = return (movToRegLiteralBool "al" 0, TBool)
compExp (EString _ s) = do
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

compExp (Neg _ e) = do
    (code, _) <- compExp e
    let negate = fromString "   neg rax\n"
    return (formatStrings [code, negate], TInt)
compExp (Not _ e) = do
    (code, _) <- compExp e
    -- score is in rax (al actually)
    let negate = fromString "   xor rax, 1\n"
    return (formatStrings [code, negate], TBool)

compExp (EVar _ (Ident x)) = do
    memory <- get
    case Map.lookup x (varEnv memory) of
        Just (loc, vt) -> do 
            let code = movToRegFromStack "rax" loc
            return (code, vt)
        Nothing -> do
            case isVarFunctionArg x (funArgs memory) 1 of
                Just (n, t) -> do
                    let code = fromString $ "   mov " ++ "rax" ++ ", [rbp + " ++ (show ((n-7)*(typeSize t) + 16)) ++ "]\n"
                    return (code, tTypeFromType t)
                Nothing -> do
                    -- it has to be a class attribute
                    -- check first argument (rdi - class instance)
                    -- and get the variable
                    memory <- get
                    -- how to know in which class to look for the variables?
                    -- it has to be stored in program memory
                    -- knowing the variable name, we know the offset - that's good
                    -- but we know the offset only after we know the classname
                    let thisClassFields = Map.findWithDefault Map.empty (currClass memory) (classEnv memory)
                    let (varOffset, varType) = Map.findWithDefault (0, TNull) x thisClassFields
                    -- let movPointerToRax = fromString $ "   mov rax, [rbp]\n"
                    -- dont use rdi, but stack
                    let getInstanceArg = fromString $ "   mov rax, [rbp - 8]\n"
                    let getClassVar = fromString $ "   mov rax, [rax + " ++ (show varOffset) ++ "]\n" 
                    return (formatStrings [getInstanceArg, getClassVar], varType)

compExp (SReadInt _) = do
    return (fromString "   call readInt\n", TInt)

compExp (SReadStr _) = do
    return (fromString "   call readString\n", TStr)

compExp (EApp pos (Ident f) exprs) = do
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

compExp (EMethod pos e (Ident f) exprs) = do
    -- its not called f, but ___classname___f___
    -- maybe broken if its in an array but ok
    (codeGetClass, (TClass className)) <- compExp e
    allSuperclasses <- gets classSuperclasses
    methodIdent <- getMethodIdentInSuperclassses className f (Map.findWithDefault [] className allSuperclasses)
    -- let methodIdent = getMethodIdent className f

    -- one difference - first argument is ALWAYS the instance of the class
    let actualExprs = (e:exprs)
    funArgsBefore <- gets funArgs
    funs <- gets classFunEnv
    funsTypes <- gets funEnvTypes
    -- modify (\st -> st {currClass = className})

    args <- getArgsFromSuperclassMethods className f
    let actualArgs = (("self", (ClassT pos (Ident className))):args)
    (prepareCode, funArgsSize) <- prepareArguments actualExprs actualArgs 1

    let fCall = fromString $ "   call " ++ methodIdent ++ "\n"
    -- let stackCleanup = fromString $ "   add rsp, " ++ show ((max ((length exprs - 6) * 8) 0)) ++ "\n"
    let stackCleanup = fromString $ "   add rsp, " ++ (show funArgsSize) ++ "\n"
    -- modify (\st -> st {funArgs = funArgsBefore})
    -- modify (\st -> st {currClass = "(null)"})
    case Map.lookup methodIdent funsTypes of
        Just vt -> return (formatStrings [prepareCode, fCall, stackCleanup], vt)
compExp (EClass _ (Ident className)) = do
    -- find the fields of the class
    memory <- get
    let classEnvs = classEnv memory
    let thisClassFields = Map.findWithDefault Map.empty className classEnvs
    let classSize = toInteger $ (Map.size thisClassFields) * 8 -- each field is 8 bytes long
    -- allocate space on the stack
    let movSizeToRdi = movToRegLiteralInt "rdi" classSize
    let allocateSpace = fromString "   call allocateClass\n"
    let code = formatStrings [movSizeToRdi, allocateSpace]
    -- now set all fields to default values
    defVals <- mapM setFieldToDefaultValues (toList thisClassFields)

    return (formatStrings [code, formatStrings defVals], TClass className)

    where
        -- varName -> (offset, varType) -> code
        setFieldToDefaultValues :: (Var, (Integer, TType)) -> CM Builder
        setFieldToDefaultValues (x, (offset, TInt)) = do
            -- set [rax + offset] to default value
            let pushR12 = pushReg "r12"
            let movValToR12 = movToRegLiteralInt "r12" 0
            let movR12ToPointer = fromString $ "   mov [rax + " ++ (show offset) ++ "], r12\n"
            let popR12 = popReg "r12"
            return $ formatStrings [pushR12, movValToR12, movR12ToPointer, popR12]
        setFieldToDefaultValues (x, (offset, TBool)) = do
            -- set [rax + offset] to default value
            let pushR12 = pushReg "r12"
            let movValToR12 = movToRegLiteralBool "r12" 0
            let movR12ToPointer = fromString $ "   mov [rax + " ++ (show offset) ++ "], r12\n"
            let popR12 = popReg "r12"
            return $ formatStrings [pushR12, movValToR12, movR12ToPointer, popR12]
        setFieldToDefaultValues (x, (offset, TStr)) = do
            -- set [rax + offset] to default value
            let pushR12 = pushReg "r12"
            let movValToR12 = fromString "   mov r12, s0\n"
            let movR12ToPointer = fromString $ "   mov [rax + " ++ (show offset) ++ "], r12\n"
            let popR12 = popReg "r12"
            return $ formatStrings [pushR12, movValToR12, movR12ToPointer, popR12]
        setFieldToDefaultValues _ = return $ fromString ""

-- Z[] zs = new Z[12];
compExp (EArrClass pos (Ident className) e) = compExp (EArr pos (ClassT pos (Ident className)) e)

compExp (EArr pos t e) = do
    let arrayType = tTypeFromType t
    let pushR12 = pushReg "r12"
    (code, vt) <- compExp e
    let movSizeToRdi = fromString "   mov rdi, rax\n"
    let movTypeSizeToRsi = fromString "   mov rsi, 8\n"
    let saveSizeToR12 = movToRegFromReg "r12" "rdi"
    let accountForLengthAttr = fromString "   add rdi, 1\n" -- first we store 8 bytes for length
    let allocateSpace = fromString "   call allocateArray\n"
    let setFirstPlaceToLen = fromString "   mov [rax], r12\n"
    let popR12 = popReg "r12"

    case arrayType of
        TStr -> do
            labelNr <- gets labelId
            let pushRax = pushReg "rax"
            let popRax = popReg "rax"
            let saveSizeToR12 = movToRegFromReg "r12" "rdi"
            let movSizeBackToRcx = movToRegFromReg "rcx" "r12"
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

    -- now the pointer is in "rax"
    -- add mapping var_name -> allocated_addr

    -- return (formatStrings [code, movSizeToRdi, movTypeSizeToRsi, allocateSpace], (TArr arrayType))

compExp (EAttr pos e (Ident field)) = do
    (codeExp, eType) <- compExp e
    case field of
        "length" -> do
            case eType of
                TArr _ -> return (formatStrings [codeExp, fromString "   mov rax, [rax]\n"], TInt)
        _ -> do
            -- other class field
            -- eType contains className, so in state you can find mapping from field to offset
            case eType of
                (TClass className) -> do
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty className (classEnv memory)
                    let (offset, fieldType) = Map.findWithDefault (0, TNull) field thisClassFields
                    -- value is in [rax + offset]
                    let getValue = fromString $ "   mov rax, [rax + " ++ (show offset) ++ "]\n"
                    return (formatStrings [codeExp, getValue], fieldType)
                (TArr (TClass className)) -> do
                    -- rax points to element in the array
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty className (classEnv memory)
                    let (offset, fieldType) = Map.findWithDefault (0, TNull) field thisClassFields
                    -- value is in [rax + offset]
                    let getValue = fromString $ "   mov rax, [rax + " ++ (show offset) ++ "]\n"
                    return (formatStrings [codeExp, getValue], fieldType)  


compExp (EVarArr pos e eInd) = do
    (codeInd, _) <- compExp eInd 
    let saveRax = pushReg "rax"
    (codeVar, vt) <- compExp e 
    let moveVarToRdi = movToRegFromReg "rdi" "rax"
    let retrieveRax = popReg "rax"
    -- now under rdi is the index where we want to look at (times 8)
    -- we want result to be [rax + 8 * rdi]
    let getFromArr = fromString "   mov rax, [rdi + 8 + 8 * rax]\n"
    return (formatStrings [codeInd, saveRax, codeVar, moveVarToRdi, retrieveRax, getFromArr], vt)

compExp (EAdd _ e1 (Plus _) e2) = do
    (code1, vt1) <- compExp e1 
    let saveRax = pushReg "rax"
    (code2, vt2) <- compExp e2
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

compExp (EAdd _ e1 (Minus _) e2) = do
    (code, _) <- compExp e1 
    let saveRdi = pushReg "rax"
    (code2, _) <- compExp e2
    let movSecondResult = movToRegFromReg "rdx" "rax"
    let retrieveRdi = popReg "rax"
    return (formatStrings [code, saveRdi, code2, movSecondResult, retrieveRdi, fromString "   sub rax, rdx\n"], TInt)

compExp (EMul _ e1 (Times _) e2) = do
    (code, _) <- compExp e1 
    -- store rdi to stack
    let saveRdi = pushReg "rax"
    (code2, _) <- compExp e2 
    -- get result to another register
    let movSecondResult = movToRegFromReg "rdx" "rax"
    let retrieveRdi = popReg "rax"
    return (formatStrings [code, saveRdi, code2, movSecondResult, retrieveRdi, fromString "   imul rax, rdx\n"], TInt)

compExp (EMul _ e1 (Div _) e2) = do
    -- save first to rax
    (code, _) <- compExp e1 
    let saveRax = pushReg "rax"
    -- let moveRdiToRax = movToRegFromReg "rax" "rdi"
    -- save second to rcx
    (code2, _) <- compExp e2 
    -- mov it to rcx
    let movSecondResult = movToRegFromReg "rcx" "rax"
    let retrieveRax = popReg "rax"
    let cqoMagic = fromString "   cqo\n"
    let divide = fromString "   idiv rcx\n"
    -- score is in rax

    let xorUpperBits = fromString $ "   xor rdx, rdx\n"
    return (formatStrings [code, saveRax, code2, movSecondResult, xorUpperBits, retrieveRax, cqoMagic, divide], TInt)

compExp (EMul _ e1 (Mod _) e2) = do
    (code, _) <- compExp e1
    let saveRax = pushReg "rax"
    (code2, _) <- compExp e2 
    let movSecondResult = movToRegFromReg "rcx" "rax"
    let retrieveRax = popReg "rax"
    let cqoMagic = fromString "   cqo\n"
    let divide = fromString "   idiv rcx\n"
    let movResultToRax = movToRegFromReg "rax"  "rdx"
    let xorUpperBits = fromString $ "   xor rdx, rdx\n"
    return (formatStrings [code, saveRax, code2, movSecondResult, xorUpperBits, retrieveRax, cqoMagic, divide, movResultToRax], TInt)

compExp (EOr _ e1 e2) = do
    (code, _) <- compExp e1 
    let checkFirst = fromString "   cmp al, 1\n"
    labelName <- gets labelId
    -- add label for else
    let finishLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let finishIfFirstTrue = fromString $ "   je " ++ finishLabel ++ "\n"
    let finishLabelCode = fromString $ finishLabel ++ ":\n"

    let saveRax = pushReg "rax"
    (code2, _) <- compExp e2
    let movSecondResult = movToRegFromReg "rcx" "rax"
    let retrieveRax = popReg "rax"
    let or = fromString "   or rax, rcx\n"
    return (formatStrings [code, checkFirst, finishIfFirstTrue, saveRax, code2, movSecondResult, retrieveRax, or, finishLabelCode], TBool)

compExp (EAnd _ e1 e2) = do
    (code, _) <- compExp e1
    let checkFirst = fromString "   cmp al, 0\n"
    labelName <- gets labelId
    -- add label for else
    let finishLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let finishIfFirstTrue = fromString $ "   je " ++ finishLabel ++ "\n"
    let finishLabelCode = fromString $ finishLabel ++ ":\n"

    let saveRax = pushReg "rax"
    (code2, _) <- compExp e2
    let movSecondResult = movToRegFromReg "rcx" "rax"
    let retrieveRax = popReg "rax"
    let and = fromString "   and rax, rcx\n"
    return (formatStrings [code, checkFirst, finishIfFirstTrue, saveRax, code2, movSecondResult, retrieveRax, and, finishLabelCode], TBool)

compExp (ERel _ e1 relOp e2) = do
    (code, _) <- compExp e1
    let movFirstResult = movToRegFromReg "rdx" "rax"
    let saveRdx = pushReg "rdx"
    (code2, _) <- compExp e2 
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