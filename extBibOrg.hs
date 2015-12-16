#!/usr/bin/env runhaskell
-- File: extBibOrg.hs
-- Copyright rejuvyesh <mail@rejuvyesh.com>, 2015
-- License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

module Main where

import Text.Pandoc
import System.Environment (getArgs)
import System.FilePath (takeExtension)

extractBib :: Pandoc -> String
extractBib (Pandoc _ bl) = concatMap f bl
  where f (CodeBlock (_,classes,_) s) | "bib" `elem` classes = s ++ "\n"
        f _ = []

processFile :: String -> String
processFile = extractBib . readDoc

readDoc :: String -> Pandoc
readDoc s = case readOrg def s of
  Right doc -> doc
  Left err -> error (show err)

main :: IO ()
main = getArgs >>= mapM readFile >>= mapM_ (putStrLn . processFile)
