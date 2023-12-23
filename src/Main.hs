module Main where

import Control.Monad.State
import System.Environment ( getArgs, getProgName )
import System.IO
import Data.Map as Map
import Latte.AbsLatte
import Latte.ErrM
import Latte.SkelLatte
import Latte.PrintLatte
import Latte.ParLatte
import Frontend.TypeChecker
import Backend.Compiler
import System.FilePath.Posix(takeBaseName, takeDirectory, dropExtension)
import System.Process
import Data.Text.Lazy.Builder
import Data.Text.Lazy.IO

runFromString :: String -> String -> IO ()
runFromString filename code = case pProgram (myLexer code) of
    Ok code -> case checkTypes code of
        Ok _ -> do
            -- output <- compile code
            -- let outputFile = dropExtension filename ++ ".s"
            -- let oFile = dropExtension filename ++ ".o"
            -- let executableFile = dropExtension filename
            -- Data.Text.Lazy.IO.writeFile outputFile (toLazyText output)
            -- system $ "nasm -f elf64 " ++ outputFile
            -- system $ "gcc -m64 -z noexecstack -no-pie lib/runtime.o -o " ++ executableFile ++ " " ++ oFile 
            System.IO.putStrLn "OK"
        Left err -> System.IO.putStrLn $ show err
    Left err -> System.IO.putStrLn err

runFromFile :: FilePath -> IO ()
runFromFile file = do
    code <- System.IO.readFile file
    runFromString file code

main :: IO () 
main = do
  args <- getArgs
  case args of
    files -> mapM_ runFromFile files