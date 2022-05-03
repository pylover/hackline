module Main where

import Control.Monad
import Control.Monad.Trans
import Control.Monad.Trans.Maybe

import HackLine.Helpers
import HackLine.CLI
import HackLine.Evaluator


getScript :: [String] -> String
getScript [] = ":~"
getScript s = spacer s


main :: IO ()
main = parseArgs >>= e >>= runMaybeT . loop 1 >> return ()
  where 
    e :: Args -> IO Evaluator
    e (Args s) = return $ evaluator (getScript s)


liftEval :: Int -> Either Signal String -> MaybeT IO Int
liftEval i (Right x) = do
  liftIO $ putStrLn x
  return (i + 1)
liftEval i (Left SuppressLine) = return i
liftEval i (Left SuppressAll) = liftIO exit >> return i


loop :: Int -> Evaluator -> MaybeT IO ()
loop i e = readLine >>= liftEval i . e i >>= (\k ->  loop k e)
