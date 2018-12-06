-- |
-- Module      : AOC2018.Prelude
-- Copyright   : (c) Justin Le 2018
-- License     : BSD3
--
-- Maintainer  : justin@jle.im
-- Stability   : experimental
-- Portability : non-portable
--
-- Custom Prelude while developing challenges.  Ideally, once challenges
-- are completed, an import to this module would be replaced with explicit
-- ones for future readers.
--


module AOC2018.Prelude (
    module P
  ) where

import           AOC2018.Solver            as P
import           AOC2018.Util              as P
import           Control.Applicative       as P
import           Control.DeepSeq           as P
import           Control.Monad             as P
import           Control.Monad.Except      as P
import           Control.Monad.State       as P
import           Data.Bifunctor            as P
import           Data.Char                 as P
import           Data.Containers.ListUtils as P
import           Data.Either               as P
import           Data.Foldable             as P
import           Data.Function             as P
import           Data.Functor              as P
import           Data.Kind                 as P
import           Data.List                 as P
import           Data.Maybe                as P
import           Data.Ord                  as P
import           Data.Semigroup            as P
import           Data.Time                 as P
import           Data.Traversable          as P
import           Data.Tuple                as P
import           Data.Void                 as P
import           Debug.Trace               as P
import           Text.Printf               as P

import           Data.Finite           as P (Finite, packFinite, getFinite, finites)
import           Data.IntMap           as P (IntMap)
import           Data.IntSet           as P (IntSet)
import           Data.List.PointedList as P (PointedList)
import           Data.Map              as P (Map)
import           Data.Profunctor       as P (Profunctor(..))
import           Data.Set              as P (Set)
import           GHC.Generics          as P (Generic)
import           Text.Read             as P (readMaybe)
