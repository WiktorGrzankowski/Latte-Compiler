module Backend.ItemCompiler where

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
import Backend.Core
import Backend.ExpCompiler (compExp)


compAllItems :: Type -> [Item] -> CM Builder

compAllItems _ [] = return $ fromString ""
compAllItems (Str pos) ((NoInit _ (Ident x)) : rest) = do
    memory <- get
    let currentOffset = stackSize memory
    modify (\st -> st {stackSize = currentOffset + 8, varEnv = Map.insert x (currentOffset, TStr) (varEnv memory)})
    let raxToDefault = fromString "   mov rax, s0\n"
    let varToDefault = movToStackFromReg currentOffset "rax"

    restCode <- compAllItems (Str pos) rest
    return $ formatStrings [raxToDefault, varToDefault, restCode]
compAllItems t ((NoInit pos (Ident x)) : rest) = do
    memory <- get
    let currentOffset = stackSize memory
    modify (\st -> st {stackSize = currentOffset + 8, varEnv = Map.insert x (currentOffset, tTypeFromType t) (varEnv memory)})
    let raxToDefault = movToRegLiteralInt "rax" 0
    let varToDefault = movToStackFromReg currentOffset "rax"

    restCode <- compAllItems t rest
    return $ formatStrings [raxToDefault, varToDefault, restCode]

compAllItems t ((Init _ (Ident x) e) : rest) = do
    (eCode, _) <- compExp e "rax"
    memory <- get
    let currentOffset = stackSize memory
    modify (\st -> st {stackSize = currentOffset + 8, varEnv = Map.insert x (currentOffset, tTypeFromType t) (varEnv memory)})
    let varToRax = movToStackFromReg currentOffset "rax"
    restCode <- compAllItems t rest
    return $ formatStrings [eCode, varToRax, restCode]
