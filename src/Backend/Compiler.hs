module Backend.Compiler where

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
import Backend.ExpCompiler (compExp, isVarFunctionArg)
import Backend.ItemCompiler (compAllItems, compItemForEachCase)
import Backend.Core
import Frontend.TypeChecker (findAllSuperClasses, prepareDeps)

emptyState :: StmtState
emptyState = StmtState { varEnv = Map.empty, 
                         funEnv = Map.empty, 
                         funEnvTypes = Map.empty,
                         classEnv = Map.empty,
                         classFunEnv = Map.empty,
                         classSuperclasses = Map.empty,
                         stackSize = 0, 
                         funArgs = [], 
                         hardcodedStrs = Map.fromList[("", "s0")], 
                         labelId = 0, 
                         funId = 0,
                         currClass = "(null)"
                        }

parseHardcodedString :: (String, String) -> Builder
parseHardcodedString (name, val) = fromString $ "   " ++ val ++ " db " ++ "'" ++ name ++ "', 0\n"

dataSectionHeader :: Map Var String -> Builder
dataSectionHeader strs = do
    let header = fromString $ "section .data\n"
    let mapAsList = Map.toList strs
    let code = Prelude.map parseHardcodedString mapAsList
    formatStrings [header, formatStrings code, fromString "\n"]


textSectionHeader :: Builder
textSectionHeader = formatStrings [
    fromString "section .text\n",
    fromString "   extern printInt\n",
    fromString "   extern printString\n",
    fromString "   extern readString\n",
    fromString "   extern concat\n",
    fromString "   extern readInt\n",
    fromString "   extern error\n",
    fromString "   extern allocateArray\n",
    fromString "   extern allocateClass\n",
    fromString "   global main\n"
    ]

emptyStack :: Integer -> Builder
emptyStack size = fromString $ "   add rsp, " ++ (show size) ++ "\n"

getArgsNames :: [Arg] -> [(String, Type)]
getArgsNames [] = []
getArgsNames ((Ar pos t (Ident x)):rest) = ((x, t):(getArgsNames rest))

compTopDef :: TopDef -> CM Builder
compTopDef (ClassDef pos (Ident x) attrs) = do
    memory <- get
    let thisClassFields = Map.findWithDefault Map.empty x (classEnv memory)
    let thisClassMethods = Map.findWithDefault Map.empty x (classFunEnv memory)
    -- modify (\st -> st {varEnv = thisClassFields, funEnv = thisClassMethods, currClass = x})
    modify (\st -> st { currClass = x})
    code <- createMethods x attrs
    return code
    where
        createMethods :: Var -> [ClassAttr] -> CM Builder
        createMethods _ [] = return $ fromString ""
        createMethods className ((ClassMethod pos fType (Ident f) args block):rest) = do
            let methodIdent = "___" ++ className ++ "___" ++ f ++ "___"
            -- args have 1 more thing - the class itself
            code <- compTopDef (FnDef pos fType (Ident methodIdent) ((Ar pos (ClassT pos (Ident className)) (Ident "self")):args) block)
            restCode <- createMethods className rest
            return $ formatStrings [code, restCode]
        createMethods className (_:rest) = createMethods className rest

compTopDef (ClassDefE pos (Ident x) (Ident parent) attrs) = do
    memory <- get
    let thisClassFields = Map.findWithDefault Map.empty x (classEnv memory)
    let thisClassMethods = Map.findWithDefault Map.empty x (classFunEnv memory)
    -- modify (\st -> st {varEnv = thisClassFields, funEnv = thisClassMethods, currClass = x})
    modify (\st -> st { currClass = x})
    code <- createMethods x attrs
    return code
    where
        createMethods :: Var -> [ClassAttr] -> CM Builder
        createMethods _ [] = return $ fromString ""
        createMethods className ((ClassMethod pos fType (Ident f) args block):rest) = do
            let methodIdent = "___" ++ className ++ "___" ++ f ++ "___"
            -- args have 1 more thing - the class itself
            code <- compTopDef (FnDef pos fType (Ident methodIdent) ((Ar pos (ClassT pos (Ident className)) (Ident "self")):args) block)
            restCode <- createMethods className rest
            return $ formatStrings [code, restCode]
        createMethods className (_:rest) = createMethods className rest
            
compTopDef (FnDef pos fType (Ident f) args block) = do    
    -- create end label

    labelName <- gets funId
    modify (\st -> st {funId = labelName + 1})
    let endLabelCode = fromString $ "end" ++ (show (labelName + 1)) ++ ":\n"
    -- first check how many assignments there are and remove from stack
    funVarsSize <- countVarsInBlock block
    let funLabel = fromString $ f ++ ":\n"
    let prologue = fromString "   push rbp\n   mov rbp, rsp\n"
    let epilogue = fromString "   pop rbp\n"

    funs <- gets funEnv
    let argsSaved = Map.findWithDefault [] f funs
    -- all function variables from registers to stack
    (rewriteArgsToStack, argsSize) <- regArgsToStack (toInteger $ length args) 1 args
    -- let argsReWritten = (toInteger $ length args)

    funArgsBefore <- gets funArgs
    varEnvBefore <- gets varEnv
    modify (\st -> st { funArgs = argsSaved, stackSize = toInteger argsSize})
    blockCode <- compBlock block
    stackAtEndOfFunction <- gets stackSize
    -- let removeFromStack = emptyStack stackAtEndOfFunction
    let removeFromStack = fromString "   mov rsp, rbp\n"
    modify (\st -> st { funArgs = funArgsBefore, varEnv = varEnvBefore})
    let stackPadding = (funVarsSize + (toInteger argsSize)) `mod` 16

    return $ formatStrings[funLabel, prologue, allocateStack (funVarsSize + (toInteger argsSize) + stackPadding), rewriteArgsToStack, blockCode, endLabelCode, removeFromStack, epilogue, fromString "   ret\n"]

compTopDef _ = do
    -- todo - code
    -- without methods nothing needs to be done actually
    return $ fromString ""


regArgsToStack :: Integer -> Integer -> [Arg] -> CM (Builder, Int)
regArgsToStack _ _ [] = return (fromString "", 0)
regArgsToStack n i ((Ar _ t (Ident x)):rest)
    | i > n = return (fromString "", 0)
    | i > 6 = return (fromString "", 0)
    | otherwise = do
        let offset = i* (toInteger $ typeSize t)
        -- TODO !!!!!
        let code = fromString ("   mov [rbp - " ++ (show offset) ++ "], " ++ (argRegister i (typeSize t)) ++ "\n")
        (restCode, restSize) <- regArgsToStack n (i+1) rest
        varEnvBefore <- gets varEnv
        modify (\st -> st { varEnv = Map.insert x (offset, tTypeFromType t) varEnvBefore})
        return (code <> restCode, restSize + (typeSize t))

countVarsInBlock :: Block -> CM Integer
countVarsInBlock (Blk _ stmts) = countLocalVars stmts

countLocalVars :: [Stmt] -> CM Integer
countLocalVars [] = return 0
countLocalVars ((Decl _ dType items):rest) = do
    let declVarsSize = toInteger $(typeSize dType) * (length items)
    restSize <- countLocalVars rest
    return $ declVarsSize + restSize
countLocalVars ((BStmt _ b):rest) = do
    blockVarsSize <- countVarsInBlock b
    restSize <- countLocalVars rest
    return $ blockVarsSize + restSize
countLocalVars (_:rest) = countLocalVars rest



compBlock :: Block -> CM Builder
compBlock (Blk _ stmts) = do 
    varsBefore <- gets varEnv
    code <- mapM compStmt stmts
    modify (\st -> st {varEnv = varsBefore})
    return $ formatStrings code

compStmt :: Stmt -> CM Builder
compStmt (Ret _ e) = do
    (code, _) <- compExp e
    myFunId <- gets funId
    let jmpToEnd = "   jmp end" ++ (show myFunId) ++ "\n"
    return $ formatStrings [code, fromString jmpToEnd]

compStmt (BStmt _ b) = compBlock b   

-- compStmt (VRet _) = return $ fromString ""
compStmt (VRet _) = do
    -- jump to my end
    myFunId <- gets funId
    let jmpToEnd = "   jmp end" ++ (show myFunId) ++ "\n"
    return $ fromString jmpToEnd
    
compStmt (SExp _ e) = do
    (code, _) <- compExp e
    return code
compStmt (Decl _ dType items) = compAllItems dType items

compStmt (SPrintInt _ e) = do
    (code, _) <- compExp e
    let move = movToRegFromReg "rdi" "rax"
    return $ formatStrings [code, move, fromString "   call printInt\n"]
compStmt (SPrintStr _ e) = do
    (code, _) <- compExp e
    let move = movToRegFromReg "rdi" "rax"
    return $ formatStrings [code, move, fromString "   call printString\n"]

compStmt (Ass _ (EVar _ (Ident x)) e) = do
    (code, _) <- compExp e 
    -- value is in rdi
    memory <- get
    case Map.lookup x (varEnv memory) of
        Just (offset, _) -> do
            let move = movToStackFromReg offset "rax"
            return $ formatStrings [code, move]
        Nothing -> do
            memory <- get
            let thisClassFields = Map.findWithDefault Map.empty (currClass memory) (classEnv memory)
            let (varOffset, varType) = Map.findWithDefault (0, TNull) x thisClassFields
            let getInstanceArg = fromString $ "   mov rax, [rbp - 8]\n"
            let getClassVar = fromString $ "   mov rax, [rax + " ++ (show varOffset) ++ "]\n" 
            let getEffectiveAddressBack = fromString "   mov rdi, [rbp - 8]\n"
            let changeActualValue = fromString $ "   mov [rdi], rax\n"
            -- todo - doesnot wokr
            return $ formatStrings [getInstanceArg, getClassVar, code, getEffectiveAddressBack, changeActualValue]

compStmt (Ass _ (EVarArr _ eIdent eInd) eVal) = do
    (codeIdent, _) <- compExp eIdent 
    let saveRax = pushReg "rax"
    (codeInd, _) <- compExp eInd 
    let movIndToRdi = movToRegFromReg "rdi" "rax"
    let saveRdi = pushReg "rdi"
    (codeVal, _) <- compExp eVal 
    let movValToRsi = movToRegFromReg "rsi" "rax"
    let retrieveRdi = popReg "rdi"
    let retrieveRax = popReg "rax"
    -- something like
    -- mov [ident + 8  * Ind], val
    let movValToArr = fromString $ "   mov [rax + 8 + " ++ "rdi * 8], rsi\n"
    return $ formatStrings [codeIdent, saveRax, codeInd, movIndToRdi, saveRax, codeVal, movValToRsi, retrieveRdi, retrieveRax, movValToArr]

compStmt (Ass pos (EAttr pos2 (EVarArr pos3 eIdent eInd) (Ident field)) eVal) = do
    -- first get the array
    (codeGetArr, (TArr (TClass className))) <- compExp (EVarArr pos3 eIdent eInd)
    -- now pointer to n-th element in the array is in rax
    let saveRax = pushReg "rax"
    (codeVal, _) <- compExp eVal 
    let movValToRdi = movToRegFromReg "rdi" "rax"
    let retrieveRax = popReg "rax"
    -- class pointer is in rax
    -- value is in rdi
    memory <- get
    let thisClassFields = Map.findWithDefault Map.empty className (classEnv memory)
    let (offset, _) = Map.findWithDefault (0, TNull) field thisClassFields
    let movValToPointer = fromString $ "   mov [rax + " ++ (show offset) ++ "], rdi\n"
    return $ formatStrings [codeGetArr, saveRax, codeVal, movValToRdi, retrieveRax, movValToPointer]
    -- then get the fiels

compStmt (Ass pos (EAttr pos2 e (Ident field)) eVal) = do
    (codeClassEval, (TClass className)) <- compExp e
    let saveRax = pushReg "rax"
    (codeVal, _) <- compExp eVal 
    let movValToRdi = movToRegFromReg "rdi" "rax"
    let retrieveRax = popReg "rax"
    -- class pointer is in rax
    -- value is in rdi
    memory <- get
    let thisClassFields = Map.findWithDefault Map.empty className (classEnv memory)
    let (offset, _) = Map.findWithDefault (0, TNull) field thisClassFields
    let movValToPointer = fromString $ "   mov [rax + " ++ (show offset) ++ "], rdi\n"
    return $ formatStrings [codeClassEval, saveRax, codeVal, movValToRdi, retrieveRax, movValToPointer]

compStmt (Incr _ (EVar _ (Ident x))) = do
    let incr = fromString "   inc rax\n"
    memory <- get
    case Map.lookup x (varEnv memory) of
        Just (offset, _) -> do
            let getFromStack = movToRegFromStack "rax" offset
            let move = movToStackFromReg offset "rax"
            return $ formatStrings [getFromStack, incr, move]
        Nothing -> do
            case isVarFunctionArg x (funArgs memory) 1 of
                Just (n, t) -> do
                    let addr = "[rbp + " ++ (show ((n-7)*(typeSize t) + 16)) ++ "]"
                    let code = fromString $ "   mov " ++ "rax" ++ ", " ++ addr ++ "\n"
                    let backToStack = fromString $ "   mov " ++ addr ++ ", rax\n"
                    return $ formatStrings [code, incr, backToStack]
                Nothing -> do
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty (currClass memory) (classEnv memory)
                    let (varOffset, varType) = Map.findWithDefault (0, TNull) x thisClassFields
                    let getInstanceArg = fromString $ "   mov rax, [rbp - 8]\n"
                    let getClassVar = fromString $ "   mov rax, [rax + " ++ (show varOffset) ++ "]\n" 
                    let getEffectiveAddressBack = fromString "   mov rdi, [rbp - 8]\n"
                    let changeActualValue = fromString $ "   mov [rdi], rax\n"
                    -- todo - doesnot wokr
                    return $ formatStrings [getInstanceArg, getClassVar, incr, getEffectiveAddressBack, changeActualValue]
compStmt (Decr _ (EVar _ (Ident x))) = do
    let decr = fromString "   dec rax\n"
    memory <- get
    case Map.lookup x (varEnv memory) of
        Just (offset, _) -> do
            let getFromStack = movToRegFromStack "rax" offset
            let move = movToStackFromReg offset "rax"
            return $ formatStrings [getFromStack, decr, move]
        Nothing -> do
            case isVarFunctionArg x (funArgs memory) 1 of
                Just (n, t) -> do
                    let addr = "[rbp + " ++ (show ((n-7)*(typeSize t) + 16)) ++ "]"
                    let code = fromString $ "   mov " ++ "rax" ++ ", " ++ addr ++ "\n"
                    let backToStack = fromString $ "   mov " ++ addr ++ ", rax\n"
                    return $ formatStrings [code, decr, backToStack]
                Nothing -> do
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty (currClass memory) (classEnv memory)
                    let (varOffset, varType) = Map.findWithDefault (0, TNull) x thisClassFields
                    let getInstanceArg = fromString $ "   mov rax, [rbp - 8]\n"
                    let getClassVar = fromString $ "   mov rax, [rax + " ++ (show varOffset) ++ "]\n" 
                    let getEffectiveAddressBack = fromString "   mov rdi, [rbp - 8]\n"
                    let changeActualValue = fromString $ "   mov [rdi], rax\n"
                    -- todo - doesnot wokr
                    return $ formatStrings [getInstanceArg, getClassVar, decr, getEffectiveAddressBack, changeActualValue]

compStmt (Cond _ cond stmt) = do
    (condCode, _) <- compExp cond
    labelName <- gets labelId
    let afterLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let checkAl = fromString "   cmp al, 1\n"
    let jumpIfNotEq = fromString $ "   jne " ++ afterLabel ++ "\n"
    stmtCode <- compStmt stmt
    let labelCode = fromString $ afterLabel ++ ":\n"
    return $ formatStrings [condCode, checkAl, jumpIfNotEq, stmtCode, labelCode]

compStmt (CondElse _ cond stmt1 stmt2) = do
    (condCode, _) <- compExp cond
    labelName <- gets labelId
    -- add label for else
    let elseLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    labelName <- gets labelId
    let afterLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let checkAl = fromString "   cmp al, 1\n"
    let jumpToElseIfNotEq = fromString $ "   jne " ++ elseLabel ++ "\n"
    let jumpToAfter = fromString $ "   jne " ++ afterLabel ++ "\n"
    stmt1Code <- compStmt stmt1
    stmt2Code <- compStmt stmt2
    let afterLabelCode = fromString $ afterLabel ++ ":\n"
    let elseLabelCode = fromString $ elseLabel ++ ":\n"
    return $ formatStrings [condCode, checkAl, jumpToElseIfNotEq, stmt1Code, jumpToAfter, elseLabelCode, stmt2Code, afterLabelCode]

-- same as if, but after stmtCode, go back to before label
-- [__initLabel__, condCode, checkAl, jumpIfNotEq, stmtCode, jmp __initLabel__, labelCode]
compStmt (While _ cond stmt) = do
    (condCode, _) <- compExp cond 
    labelName <- gets labelId
    let condLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})   
    labelName <- gets labelId
    let afterLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let checkAl = fromString "   cmp al, 1\n"
    let jumpIfNotEq = fromString $ "   jne " ++ afterLabel ++ "\n"
    stmtCode <- compStmt stmt
    let labelCode = fromString $ afterLabel ++ ":\n"
    let labelCondCode = fromString $ condLabel ++ ":\n"
    let jmpLabelCond = fromString $ "   jmp " ++ condLabel ++ "\n"
    return $ formatStrings [labelCondCode, condCode, checkAl, jumpIfNotEq, stmtCode, jmpLabelCond, labelCode]

compStmt (ForEach pos t (Ident x) e stmt) = do
    -- now loop over elements and each time apply stmt with x mapped to [rax]
    -- compAllItems t ((NoInit pos (Ident x)) : rest) 
    (eCode, _) <- compExp e 
    memory <- get
    redefineX <- compItemForEachCase t (NoInit pos (Ident x))
    let movLenToR12 = fromString "   mov r12, [rax]\n"
    let movRaxToFirstElem = fromString "   add rax, 8\n"
    let movArrToR11 = movToRegFromReg "r13" "rax"

    let labelNr = labelId memory
    modify (\st -> st {labelId = labelNr + 1})
    let labelName = "forEach" ++ (show (labelNr + 1))
    let labelCode = fromString $ labelName ++ ":\n"
    let labelEndName = labelName ++ "end"
    let labelEndCode = fromString $ labelEndName ++ ":\n"
    let checkIfEmptyArr = fromString "   test r12, r12\n"
    let gotoEndIfEmptyArr = fromString $ "   jz " ++ labelEndName ++ "\n"
    let loopAgain = fromString $ "   add r13, 8\n   dec r12\n   jnz " ++ labelName ++ "\n"

    let spaceForIterator = fromString "   sub rsp, 8\n"
    let deletSpaceForIterator = fromString "   add rsp, 8\n"

    stmtCode <- compStmt stmt



    modify (\st -> st {stackSize = stackSize memory, varEnv = varEnv memory})

    return $ formatStrings[eCode, movLenToR12, movRaxToFirstElem, movArrToR11, spaceForIterator, checkIfEmptyArr, gotoEndIfEmptyArr, labelCode, redefineX, stmtCode, loopAgain, labelEndCode, deletSpaceForIterator ]




getExpLocation :: Expr -> CM Builder
getExpLocation (ELitInt _ i) = return $ fromString $ show i ++ "\n"
getExpLocation (EVar _ (Ident x)) = do
    vars <- gets varEnv
    case Map.lookup x vars of
        Just (offset, _) -> return $ fromString $ "[rbp - " ++ (show offset) ++ "]\n"

preprodAll :: [TopDef] -> CM ()
preprodAll [] = return ()
preprodAll ((FnDef pos fType (Ident f) args block):rest) = do
    let argsNames = getArgsNames args
    funs <- gets funEnv
    funsTypes <- gets funEnvTypes
    modify (\st -> st { funEnv = Map.insert f argsNames funs, funEnvTypes = Map.insert f (tTypeFromType fType) funsTypes})
    preprodAll rest

-- add className to state and its variables
-- for now ignore any inheritance
preprodAll ((ClassDef pos (Ident x) attrs):rest) = do
    -- parse all attributes
    modify (\st -> st {classEnv = Map.insert x Map.empty (classEnv st)})
    (fields, methods) <- parseAttrs x attrs

    modify (\st -> st {classEnv = Map.insert x fields (classEnv st), classFunEnv = Map.insert x methods (classFunEnv st)})
    preprodAll rest

preprodAll ((ClassDefE _ (Ident x) (Ident parent) attrs):rest) = do
    -- parse all attributes
    modify (\st -> st {classEnv = Map.insert x Map.empty (classEnv st), classFunEnv = Map.insert x Map.empty (classFunEnv st)})
    (fields, methods) <- parseAttrs x attrs
    modify (\st -> st {classEnv = Map.insert x fields (classEnv st), classFunEnv = Map.insert x methods (classFunEnv st)})
    preprodAll rest


-- Map <className, Map <attrName, offset in class>>
parseAttrs :: Var -> [ClassAttr] -> CM (Map Var (Integer, TType), Map Var [(String, Type)])
parseAttrs classIdent attrs = helper classIdent attrs Map.empty 0 Map.empty where
    helper :: Var -> [ClassAttr] -> Map Var (Integer, TType) -> Integer -> Map Var [(String, Type)] -> CM (Map Var (Integer, TType), Map Var [(String, Type)])
    helper _ [] mAttr _ mFun = return (mAttr, mFun)
    helper className ((ClassField _ t (Ident x)):rest) mAttr offset mFun = do
        helper className rest (Map.insert x (offset, tTypeFromType t) mAttr) (offset + 8) mFun
    helper className ((ClassMethod pos fType (Ident f) args block):rest) mAttr offset mFun = do
        let methodIdent = "___" ++ className ++ "___" ++ f ++ "___"
        modify (\st -> st {funEnvTypes = Map.insert methodIdent (tTypeFromType fType) (funEnvTypes st)})
        helper className rest mAttr offset (Map.insert methodIdent (parseArgs args []) mFun)

    parseArgs :: [Arg] -> [(String, Type)] -> [(String, Type)]
    parseArgs [] acc = acc
    parseArgs ((Ar pos t (Ident x)):rest) acc = parseArgs rest ((x, t):acc)

getFieldsFromSuperclasses :: CM ()
getFieldsFromSuperclasses = do
    memory <- get
    let baseClasses = Map.keys (classSuperclasses memory)
    helper baseClasses (classSuperclasses memory)
    where
        -- update fields for baseClasses with fields of their superClasses
        helper :: [Var] -> Map Var [Var] -> CM ()
        helper [] _ = return ()
        helper (className:rest) envSupers = do
            --iterate over all superclasses and add fields
            let superclasses = Map.findWithDefault [] className envSupers
            go className superclasses
            helper rest envSupers
        -- for a given baseClass, update with fields of superclasses
        go :: Var -> [Var] -> CM ()
        go _ [] = return ()
        go className (super:rest) = do
            classFields <- gets classEnv 
            let superFields = Map.findWithDefault Map.empty super classFields
            let baseFields = Map.findWithDefault Map.empty className classFields
            go2 className baseFields superFields
            go className rest
        
        go2 :: Var ->  Map Var (Integer, TType) -> Map Var (Integer, TType) -> CM ()
        go2 className baseClass superClass = do
            -- Get the current state
            currentSt <- get

            -- Process the superClass fields
            let newBaseClass = Prelude.foldr (processField baseClass) baseClass (Map.toList superClass)

            -- Update the state
            let newSt = currentSt { classEnv = Map.insert className newBaseClass (classEnv currentSt) }
            put newSt

        -- Helper function to process each field of the superClass
        processField :: Map Var (Integer, TType) -> (Var, (Integer, TType)) -> Map Var (Integer, TType) -> Map Var (Integer, TType)
        processField baseClass (var, (offset, ttype)) acc =
            if Map.member var baseClass
            then acc  -- If the field exists in the baseClass, do nothing
            else Map.insert var (newOffset, ttype) acc  -- Insert with updated offset
            where
                maxOffset = maximum $ 0 : Prelude.map fst (Map.elems baseClass)
                newOffset = maxOffset + 8

preprodInheritance :: [TopDef] -> CM ()
preprodInheritance topDefs = modify (\st -> st {classSuperclasses = findAllSuperClasses (prepareDeps topDefs Map.empty)}) >> return ()

compileAll :: [TopDef] -> CM Builder
compileAll topDefs = do
    preprodInheritance topDefs
    preprodAll topDefs
    getFieldsFromSuperclasses
    code <- mapM compTopDef topDefs
    strs <- gets hardcodedStrs
    return $ formatStrings [dataSectionHeader strs, textSectionHeader, formatStrings code]

handleErr :: CompilerError -> CM Builder
handleErr err = return $ fromString $ show err

compile :: Program -> IO Builder
compile (Prog _ topDefs) = do
    (program, _) <- runStateT (runExceptT (catchError (compileAll topDefs) handleErr)) emptyState
    case program of
        Left err -> return $ fromString "error"
        Right code -> return code
