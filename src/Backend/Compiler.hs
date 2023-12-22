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
import Backend.ExpCompiler (compExp)
import Backend.ItemCompiler (compAllItems)
import Backend.Core

emptyState :: StmtState
emptyState = StmtState { varEnv = Map.empty, 
                         funEnv = Map.empty, 
                         funEnvTypes = Map.empty,
                         stackSize = 0, 
                         funArgs = [], 
                         hardcodedStrs = Map.fromList[("", "s0")], 
                         labelId = 0, 
                         funId = 0
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
    fromString "   global main\n"
    ]

emptyStack :: Integer -> Builder
emptyStack size = fromString $ "   add rsp, " ++ (show size) ++ "\n"

getArgsNames :: [Arg] -> [(String, Type)]
getArgsNames [] = []
getArgsNames ((Ar pos t (Ident x)):rest) = ((x, t):(getArgsNames rest))

compTopDef :: TopDef -> CM Builder
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
    (code, _) <- compExp e "rax"
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
    (code, _) <- compExp e "rax"
    return code
compStmt (Decl _ dType items) = compAllItems dType items

compStmt (SPrintInt _ e) = do
    (code, _) <- compExp e "rax"
    let move = movToRegFromReg "rdi" "rax"
    return $ formatStrings [code, move, fromString "   call printInt\n"]
compStmt (SPrintStr _ e) = do
    (code, _) <- compExp e "rax"
    let move = movToRegFromReg "rdi" "rax"
    return $ formatStrings [code, move, fromString "   call printString\n"]

compStmt (Ass _ (EVar _ (Ident x)) e) = do
    (code, _) <- compExp e "rax"
    -- value is in rdi
    memory <- get
    case Map.lookup x (varEnv memory) of
        -- todo - now only rdi as i care about integers, add strings later
        Just (offset, _) -> do
            let move = movToStackFromReg offset "rax"
            return $ formatStrings [code, move]

compStmt (Ass _ (EVarArr _ eIdent eInd) eVal) = do
    (codeIdent, _) <- compExp eIdent "rax"
    let saveRax = pushReg "rax"
    (codeInd, _) <- compExp eInd "rax"
    let movIndToRdi = movToRegFromReg "rdi" "rax"
    let saveRdi = pushReg "rdi"
    (codeVal, _) <- compExp eVal "rax"
    let movValToRsi = movToRegFromReg "rsi" "rax"
    let retrieveRdi = popReg "rdi"
    let retrieveRax = popReg "rax"
    -- something like
    -- mov [ident + 8  * Ind], val
    let movValToArr = fromString $ "   mov [rax + 8 + " ++ "rdi * 8], rsi\n"
    return $ formatStrings [codeIdent, saveRax, codeInd, movIndToRdi, saveRax, codeVal, movValToRsi, retrieveRdi, retrieveRax, movValToArr]


compStmt (Incr _ (EVar _ (Ident x))) = do
    let incr = fromString "   inc rax\n"
    memory <- get
    case Map.lookup x (varEnv memory) of
        Just (offset, _) -> do
            let getFromStack = movToRegFromStack "rax" offset
            let move = movToStackFromReg offset "rax"
            return $ formatStrings [getFromStack, incr, move]

compStmt (Decr _ (EVar _ (Ident x))) = do
    let decr = fromString "   dec rax\n"
    memory <- get
    case Map.lookup x (varEnv memory) of
        Just (offset, _) -> do
            let getFromStack = movToRegFromStack "rax" offset
            let move = movToStackFromReg offset "rax"
            return $ formatStrings [getFromStack, decr, move]


compStmt (Cond _ cond stmt) = do
    (condCode, _) <- compExp cond "rax"
    labelName <- gets labelId
    let afterLabel = "l" ++ (show labelName)
    modify (\st -> st {labelId = labelName + 1})
    let checkAl = fromString "   cmp al, 1\n"
    let jumpIfNotEq = fromString $ "   jne " ++ afterLabel ++ "\n"
    stmtCode <- compStmt stmt
    let labelCode = fromString $ afterLabel ++ ":\n"
    return $ formatStrings [condCode, checkAl, jumpIfNotEq, stmtCode, labelCode]

compStmt (CondElse _ cond stmt1 stmt2) = do
    (condCode, _) <- compExp cond "rax"
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
    (condCode, _) <- compExp cond "rax"
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

compileAll :: [TopDef] -> CM Builder
compileAll topDefs = do
    preprodAll topDefs
    code <- mapM compTopDef topDefs
    strs <- gets hardcodedStrs
    return $ formatStrings [dataSectionHeader strs, textSectionHeader, formatStrings code]

handleErr :: CompilerError -> CM Builder
handleErr err = return $ fromString $ show err

compile :: Program -> IO Builder
compile (Prog _ topDefs) = do
    (program, _) <- runStateT (runExceptT (catchError (compileAll topDefs) handleErr)) emptyState
    case program of
        Left err -> return $ fromString "kodzik"
        Right code -> return code
