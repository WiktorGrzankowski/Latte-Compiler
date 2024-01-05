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

    let newOffset = currentOffset + 8
    let raxToDefault = movToRegDefaultString "rax"
    let varToDefault = movToStackFromReg newOffset "rax"

    modify (\st -> st {stackSize = newOffset, varEnv = Map.insert x (newOffset, TStr) (varEnv memory)})
    restCode <- compAllItems (Str pos) rest
    return $ formatStrings [raxToDefault, varToDefault, restCode]

compAllItems t ((NoInit pos (Ident x)) : rest) = do
    memory <- get
    let currentOffset = stackSize memory
    let newOffset = currentOffset + 8

    let raxToDefault = movToRegLiteralInt "rax" 0
    let varToDefault = movToStackFromReg newOffset "rax"

    modify (\st -> st {stackSize = newOffset, varEnv = Map.insert x (newOffset, tTypeFromType t) (varEnv memory)})
    restCode <- compAllItems t rest
    return $ formatStrings [raxToDefault, varToDefault, restCode]
    
compAllItems t ((Init _ (Ident x) e) : rest) = do
    (eCode, eType) <- compExp e
    memory <- get
    let currentOffset = stackSize memory
    let newOffset = currentOffset + 8

    let varToRax = movToStackFromReg newOffset "rax"

    modify (\st -> st {stackSize = newOffset, varEnv = Map.insert x (newOffset, eType) (varEnv memory)})
    restCode <- compAllItems t rest
    return $ formatStrings [eCode, varToRax, restCode]

compItemForEachCase :: Type -> Item -> CM Builder
compItemForEachCase t (NoInit pos (Ident x)) = do
    memory <- get
    let currentOffset = stackSize memory
    let newOffset = currentOffset + 8 
    let getValueOfR13 = movToRegFromRegVal "r14" "r13"
    let varToRax = movToStackFromReg newOffset "r14"
  
    modify (\st -> st {stackSize = newOffset, varEnv = Map.insert x (newOffset, tTypeFromType t) (varEnv memory)})
    return $ formatStrings[getValueOfR13, varToRax]
    
