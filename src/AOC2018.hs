-- |
-- Module      : AOC2018
-- Copyright   : (c) Justin Le 2018
-- License     : BSD3
--
-- Maintainer  : justin@jle.im
-- Stability   : experimental
-- Portability : non-portable
--
-- Single-stop entry point for the library's functionality and all
-- challenge solutions.
--

module AOC2018 (
    module AOC
  ) where

import           AOC2018.Challenge       as AOC
import           AOC2018.Run             as AOC
import           AOC2018.Run.Config      as AOC
import           AOC2018.Run.Interactive as AOC
import           AOC2018.Run.Load        as AOC
import           AOC2018.Solver          as AOC
import           AOC2018.Util            as AOC

