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
                         currClass = noCurrClass
                        }

parseHardcodedString :: (String, String) -> Builder
parseHardcodedString (name, val) = fromString $ "   " ++ val ++ " db " ++ "\"" ++ name ++ "\", 0\n"

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
    fromString "   global main\n\n"
    ]

emptyStack :: Integer -> Builder
emptyStack size = addCall rspR (show size)

getArgsNames :: [Arg] -> [(String, Type)]
getArgsNames [] = []
getArgsNames ((Ar pos t (Ident x)):rest) = ((x, t):(getArgsNames rest))

compTopDef :: TopDef -> CM Builder
compTopDef (ClassDef pos (Ident x) attrs) = do
    memory <- get
    let thisClassFields = Map.findWithDefault Map.empty x (classEnv memory)
    let thisClassMethods = Map.findWithDefault Map.empty x (classFunEnv memory)
    modify (\st -> st { currClass = x})
    code <- createMethods x attrs
    modify (\st -> st {currClass = noCurrClass})
    return code
    where
        createMethods :: Var -> [ClassAttr] -> CM Builder
        createMethods _ [] = return emptyCode
        createMethods className ((ClassMethod pos fType (Ident f) args block):rest) = do
            let methodIdent = getMethodIdent className f
            -- args have 1 more thing - the class instance
            code <- compTopDef (FnDef pos fType (Ident methodIdent) ((Ar pos (ClassT pos (Ident className)) (Ident "self")):args) block)
            restCode <- createMethods className rest
            return $ formatStrings [code, restCode]
        createMethods className (_:rest) = createMethods className rest

compTopDef (ClassDefE pos (Ident x) (Ident parent) attrs) = compTopDef (ClassDef pos (Ident x) attrs)
            
compTopDef (FnDef pos fType (Ident f) args block) = do    
    labelName <- gets funId
    modify (\st -> st {funId = labelName + 1})
    let endLabelCode = fromString $ "end" ++ (show (labelName + 1)) ++ ":\n"
    funVarsSize <- countVarsInBlock block
    let funLabel = labelToCode f
    let prologue = formatStrings [pushReg rbpR, movToRegFromReg rbpR rspR]
    let epilogue = popReg rbpR
    funs <- gets funEnv
    let argsSaved = Map.findWithDefault [] f funs
    (rewriteArgsToStack, argsSize) <- regArgsToStack (toInteger $ length args) 1 args
    funArgsBefore <- gets funArgs
    varEnvBefore <- gets varEnv
    modify (\st -> st { funArgs = argsSaved, stackSize = toInteger argsSize})
    blockCode <- compBlock block
    stackAtEndOfFunction <- gets stackSize
    let removeFromStack = movToRegFromReg rspR rbpR
    modify (\st -> st { funArgs = funArgsBefore, varEnv = varEnvBefore})
    let stackPadding = (funVarsSize + (toInteger argsSize)) `mod` 16
    return $ formatStrings[funLabel, prologue, allocateStack (funVarsSize + (toInteger argsSize) + stackPadding), rewriteArgsToStack, blockCode, endLabelCode, removeFromStack, epilogue, fromString "   ret\n"]



regArgsToStack :: Integer -> Integer -> [Arg] -> CM (Builder, Int)
regArgsToStack _ _ [] = return (fromString "", 0)
regArgsToStack n i ((Ar _ t (Ident x)):rest)
    | i > n = return (fromString "", 0)
    | i > 6 = return (fromString "", 0)
    | otherwise = do
        let offset = i* (toInteger $ typeSize t)
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
    let jmpToEnd = jmpTo ("end" ++ (show myFunId))
    return $ formatStrings [code, jmpToEnd]

compStmt (Empty _) = return emptyCode
compStmt (BStmt _ b) = compBlock b   

compStmt (VRet _) = do
    myFunId <- gets funId
    let jmpToEnd = jmpTo ("end" ++ (show myFunId))
    return jmpToEnd
    
compStmt (SExp _ e) = do
    (code, _) <- compExp e
    return code
compStmt (Decl _ dType items) = compAllItems dType items

compStmt (SPrintInt _ e) = do
    (code, _) <- compExp e
    let move = movToRegFromReg rdiR raxR
    return $ formatStrings [code, move, callFun "printInt"]
compStmt (SPrintStr _ e) = do
    (code, _) <- compExp e
    let move = movToRegFromReg rdiR raxR
    return $ formatStrings [code, move, callFun "printString"]

compStmt (Ass _ (EVar _ (Ident x)) e) = do
    (code, eType) <- compExp e 
    memory <- get
    let (currentVarOff, currentVarT) = Map.findWithDefault (0, TNull) x (varEnv memory)
    modify (\st -> st {varEnv = Map.insert x (currentVarOff, eType) (varEnv st)})
    case Map.lookup x (varEnv memory) of
        Just (offset, _) -> do
            let move = movToStackFromReg offset raxR
            return $ formatStrings [code, move]
        Nothing -> do
            memory <- get
            let thisClassFields = Map.findWithDefault Map.empty (currClass memory) (classEnv memory)
            let (varOffset, varType) = Map.findWithDefault (0, TNull) x thisClassFields
            let getInstanceArg = movToRegSelfArg raxR
            let getClassVar = movToRegFromReg raxR (regValAtOffset raxR (show varOffset))
            let getEffectiveAddressBack = movToRegSelfArg rdiR
            let (xOffset, xT) = Map.findWithDefault (0, TNull) x thisClassFields
            let changeActualValue = movToRegFromReg (regValAtOffset rdiR (show xOffset)) raxR
            return $ formatStrings [getInstanceArg, getClassVar, code, getEffectiveAddressBack, changeActualValue]

compStmt (Ass _ (EVarArr _ eIdent eInd) eVal) = do
    (codeIdent, _) <- compExp eIdent 
    let saveRax = pushReg raxR
    (codeInd, _) <- compExp eInd 
    let movIndToRdi = movToRegFromReg rdiR raxR
    let saveRdi = pushReg rdiR
    (codeVal, _) <- compExp eVal 
    let movValToRsi = movToRegFromReg rsiR raxR
    let retrieveRdi = popReg rdiR
    let retrieveRax = popReg raxR
    let movValToArr = fromString $ "   mov [rax + 8 + " ++ "rdi * 8], rsi\n"
    return $ formatStrings [codeIdent, saveRax, codeInd, movIndToRdi, saveRax, codeVal, movValToRsi, retrieveRdi, retrieveRax, movValToArr]

compStmt (Ass pos (EAttr pos2 (EVarArr pos3 eIdent eInd) (Ident field)) eVal) = do
    (codeGetArr, (TArr (TClass className))) <- compExp (EVarArr pos3 eIdent eInd)
    let saveRax = pushReg raxR
    (codeVal, _) <- compExp eVal 
    let movValToRdi = movToRegFromReg rdiR raxR
    let retrieveRax = popReg raxR
    memory <- get
    let thisClassFields = Map.findWithDefault Map.empty className (classEnv memory)
    let (offset, _) = Map.findWithDefault (0, TNull) field thisClassFields
    let movValToPointer = movToRegFromReg (regValAtOffset raxR (show offset)) rdiR
    return $ formatStrings [codeGetArr, saveRax, codeVal, movValToRdi, retrieveRax, movValToPointer]

compStmt (Ass pos (EAttr pos2 e (Ident field)) eVal) = do
    (codeClassEval, (TClass className)) <- compExp e
    let saveRax = pushReg raxR
    (codeVal, _) <- compExp eVal 
    let movValToRdi = movToRegFromReg rdiR raxR
    let retrieveRax = popReg raxR
    memory <- get
    let thisClassFields = Map.findWithDefault Map.empty className (classEnv memory)
    let (offset, _) = Map.findWithDefault (0, TNull) field thisClassFields
    let movValToPointer = movToRegFromReg (regValAtOffset raxR (show offset)) rdiR
    return $ formatStrings [codeClassEval, saveRax, codeVal, movValToRdi, retrieveRax, movValToPointer]

compStmt (Incr _ (EVar _ (Ident x))) = do
    let incr = fromString "   inc rax\n"
    memory <- get
    case Map.lookup x (varEnv memory) of
        Just (offset, _) -> do
            let getFromStack = movToRegFromStack raxR offset
            let move = movToStackFromReg offset raxR
            return $ formatStrings [getFromStack, incr, move]
        Nothing -> do
            case isVarFunctionArg x (funArgs memory) 1 of
                Just (n, t) -> do
                    let addr = "[rbp + " ++ (show ((n-7)*(typeSize t) + 16)) ++ "]"
                    let code = fromString $ "   mov " ++ raxR ++ ", " ++ addr ++ "\n"
                    let backToStack = fromString $ "   mov " ++ addr ++ ", rax\n"
                    return $ formatStrings [code, incr, backToStack]
                Nothing -> do
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty (currClass memory) (classEnv memory)
                    let (varOffset, varType) = Map.findWithDefault (0, TNull) x thisClassFields
                    let getInstanceArg = movToRegSelfArg raxR
                    let getClassVar = movToRegFromReg raxR (regValAtOffset raxR (show varOffset))
                    let getEffectiveAddressBack =  movToRegSelfArg rdiR
                    let changeActualValue = movToRegFromReg (regValAtOffset rdiR (show 0)) raxR
                    return $ formatStrings [getInstanceArg, getClassVar, incr, getEffectiveAddressBack, changeActualValue]
    
compStmt (Decr _ (EVar _ (Ident x))) = do
    let decr = fromString "   dec rax\n"
    memory <- get
    case Map.lookup x (varEnv memory) of
        Just (offset, _) -> do
            let getFromStack = movToRegFromStack raxR offset
            let move = movToStackFromReg offset raxR
            return $ formatStrings [getFromStack, decr, move]
        Nothing -> do
            case isVarFunctionArg x (funArgs memory) 1 of
                Just (n, t) -> do
                    let addr = "[rbp + " ++ (show ((n-7)*(typeSize t) + 16)) ++ "]"
                    let code = fromString $ "   mov " ++ raxR ++ ", " ++ addr ++ "\n"
                    let backToStack = fromString $ "   mov " ++ addr ++ ", rax\n"
                    return $ formatStrings [code, decr, backToStack]
                Nothing -> do
                    memory <- get
                    let thisClassFields = Map.findWithDefault Map.empty (currClass memory) (classEnv memory)
                    let (varOffset, varType) = Map.findWithDefault (0, TNull) x thisClassFields
                    let getInstanceArg = movToRegSelfArg raxR
                    let getClassVar = movToRegFromReg raxR (regValAtOffset raxR (show varOffset))
                    let getEffectiveAddressBack =  movToRegSelfArg rdiR
                    let changeActualValue = movToRegFromReg (regValAtOffset rdiR (show 0)) raxR
                    -- todo - doesnot wokr
                    return $ formatStrings [getInstanceArg, getClassVar, decr, getEffectiveAddressBack, changeActualValue]

compStmt (Cond _ cond stmt) = do
    (condCode, _) <- compExp cond
    labelName <- gets labelId
    let afterLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let checkAl = compareCall alR (show 1)
    let jumpIfNotEq = jneTo afterLabel
    stmtCode <- compStmt stmt
    let labelCode = labelToCode afterLabel
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
    let checkAl = compareCall alR (show 1)
    let jumpToElseIfNotEq = jneTo elseLabel
    let jumpToAfter = jmpTo afterLabel
    stmt1Code <- compStmt stmt1
    stmt2Code <- compStmt stmt2
    let afterLabelCode = labelToCode afterLabel
    let elseLabelCode = labelToCode elseLabel
    return $ formatStrings [condCode, checkAl, jumpToElseIfNotEq, stmt1Code, jumpToAfter, elseLabelCode, stmt2Code, afterLabelCode]

compStmt (While _ cond stmt) = do
    (condCode, _) <- compExp cond 
    labelName <- gets labelId
    let condLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})   
    labelName <- gets labelId
    let afterLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let checkAl = compareCall alR (show 1)
    let jumpIfNotEq = jneTo afterLabel
    stmtCode <- compStmt stmt
    let labelCode =  labelToCode afterLabel
    let labelCondCode = labelToCode condLabel
    let jmpLabelCond = jmpTo condLabel
    return $ formatStrings [labelCondCode, condCode, checkAl, jumpIfNotEq, stmtCode, jmpLabelCond, labelCode]

compStmt (ForEach pos t (Ident x) e stmt) = do
    (eCode, _) <- compExp e 
    memory <- get
    redefineX <- compItemForEachCase t (NoInit pos (Ident x))
    let movLenToR12 = addCall r12R (regValAtOffset raxR (show 0))
    let movRaxToFirstElem = addCall raxR (show 8)
    let movArrToR11 = movToRegFromReg r13R raxR

    let labelNr = labelId memory
    modify (\st -> st {labelId = labelNr + 1})
    let labelName = "forEach" ++ (show (labelNr + 1))
    let labelCode = labelToCode labelName
    let labelEndName = labelName ++ "end"
    let labelEndCode = labelToCode labelEndName
    let checkIfEmptyArr = fromString "   test r12, r12\n"
    let gotoEndIfEmptyArr = fromString $ "   jz " ++ labelEndName ++ "\n"
    let loopAgain = fromString $ "   add r13, 8\n   dec r12\n   jnz " ++ labelName ++ "\n"

    let spaceForIterator = subCall rspR (show 8)
    let deletSpaceForIterator = addCall rspR (show 8)

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
    modify (\st -> st {classEnv = Map.insert x Map.empty (classEnv st), classFunEnv = Map.insert x Map.empty (classFunEnv st)})
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
        let methodIdent = getMethodIdent className f
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
        helper :: [Var] -> Map Var [Var] -> CM ()
        helper [] _ = return ()
        helper (className:rest) envSupers = do
            -- Get all fields from superclasses recursively and update the current class fields
            let thisClassSupers = Map.findWithDefault [] className envSupers
            allSuperFields <- getAllSuperFields className (reverse (className:thisClassSupers))
            -- updateClassFields className allSuperFields
            helper rest envSupers
            modify (\st -> st {classEnv = Map.insert className allSuperFields (classEnv st)})

        getAllSuperFields :: Var -> [Var] -> CM (Map Var (Integer, TType))
        getAllSuperFields baseName superNames = getAllSuperFieldsHelper baseName superNames Map.empty
            where
                getAllSuperFieldsHelper :: Var -> [Var] -> (Map Var (Integer, TType)) -> CM (Map Var (Integer, TType))
                getAllSuperFieldsHelper _ [] accMap = return accMap
                getAllSuperFieldsHelper baseName (superName:otherNames) accMap  = do
                    memory <- get
                    let superClassFields = Map.findWithDefault Map.empty superName (classEnv memory) -- all fields
                    let nextOffsetSize = toInteger $ (Map.size accMap) * 8
                    let newAccMap = mergeMaps accMap superClassFields nextOffsetSize
                    getAllSuperFieldsHelper baseName otherNames newAccMap 

                mergeMaps :: Map.Map Var (Integer, TType) -> Map.Map Var (Integer, TType) -> Integer -> Map.Map Var (Integer, TType)
                mergeMaps m1 m2 offset = Map.union m1 updatedM2
                    where
                        updatedM2 = Map.mapWithKey updateOffset m2

                        updateOffset :: Var -> (Integer, TType) -> (Integer, TType)
                        updateOffset key (value, ttype) =
                            if Map.member key m1
                            then (value, ttype)  
                            else (value + offset, ttype)

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
        Right code -> return code
