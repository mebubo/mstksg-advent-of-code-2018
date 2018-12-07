-- |
-- Module      : AOC2018.Solver
-- Copyright   : (c) Justin Le 2018
-- License     : BSD3
--
-- Maintainer  : justin@jle.im
-- Stability   : experimental
-- Portability : non-portable
--
-- Types to drive the challenge runner and help speed up/clean up
-- solutions.
--

module AOC2018.Solver (
    (:~>)(..)
  , withSolver, withSolver'
  , SomeSolution(..)
  , SolutionError(..)
  , runSolution
  , runSomeSolution
  -- * 'DynoMap'
  , runSolutionWith
  , runSomeSolutionWith
  , fromDyno
  , fromDyno_
  ) where

import           AOC2018.Util
import           AOC2018.Util.DynoMap
import           Control.DeepSeq
import           Data.Dynamic
import           Data.Map             (Map)
import           GHC.Generics         (Generic)
import           GHC.TypeLits

-- | Abstracting over the type of a challenge solver to help with cleaner
-- solutions.
--
-- A @a ':~>' b@ encapsulates something that solves a challenge with input
-- type @a@ into a response of type @b@.
--
-- Consists of a parser, a shower, and a solver.  The solver solves
-- a general @a -> 'Maybe' b@ function, and the parser and shower are used
-- to handle the boilerplate of parsing and printing the solution.
data a :~> b = MkSol
    { sParse :: String -> Maybe a    -- ^ parse input into an @a@
    , sSolve :: (?dyno :: DynoMap)
             => a      -> Maybe b    -- ^ solve an @a@ input to a @b@ solution
    , sShow  :: b      -> String     -- ^ print out the @b@ solution in a pretty way
    }

-- | Wrap an @a ':~>' b@ and hide the type variables so we can put
-- different solutions in a container.
data SomeSolution where
    MkSomeSol :: a :~> b -> SomeSolution

-- | Errors that might happen when running a ':~>' on some input.
data SolutionError = SEParse
                   | SESolve
  deriving (Show, Eq, Ord, Generic)

instance NFData SolutionError

-- | Construct a ':~>' from just a normal @String -> String@ solver.
-- Does no parsing or special printing treatment.
withSolver' :: (String -> String) -> String :~> String
withSolver' f = withSolver (Just . f)

-- | Construct a ':~>' from a @String -> 'Maybe' String@ solver, which
-- might fail.  Does no parsing or special printing treatment.
withSolver :: (String -> Maybe String) -> String :~> String
withSolver f = MkSol
    { sParse = Just
    , sShow  = id
    , sSolve = f
    }

-- | Run a ':~>' on some input.
runSolution :: a :~> b -> String -> Either SolutionError String
runSolution = runSolutionWith mempty

-- | Run a ':~>' on some input, with a map of dynamic values for testing
runSolutionWith
    :: Map String Dynamic       -- ^ map of dynamic values for testing with 'lookupDyno'.
    -> a :~> b
    -> String
    -> Either SolutionError String
runSolutionWith dm MkSol{..} (strip->s) = do
    x <- maybeToEither SEParse . sParse $ s
    y <- maybeToEither SESolve . sSolve $ x
    pure $ sShow y
  where
    ?dyno = Dyno dm

-- | Run a 'SomeSolution' on some input.
runSomeSolution
    :: SomeSolution
    -> String
    -> Either SolutionError String
runSomeSolution = runSomeSolutionWith mempty

-- | Run a 'SomeSolution' on some input, with a map of dynamic values for
-- testing
runSomeSolutionWith
    :: Map String Dynamic       -- ^ map of dynamic values for testing with 'lookupDyno'.
    -> SomeSolution
    -> String
    -> Either SolutionError String
runSomeSolutionWith dm (MkSomeSol c) = runSolutionWith dm c

-- | From a @?dyno@ Implicit Params, look up a value at a given key.  Meant
-- to be used with TypeApplications:
--
-- > fromDyno @"hello"
--
-- This can be used within the body of 'sSolve', since it will always be
-- called with the implicit parameter.
--
-- When called on actual puzzle input, result will always be 'Nothing'.
-- But, for some test inputs, there might be supplied values.
--
-- This is useful for when some problems have parameters that are
-- different with test inputs than for actual inputs.
fromDyno
    :: forall (sym :: Symbol) a. (KnownSymbol sym, Typeable a, ?dyno :: DynoMap)
    => Maybe a
fromDyno = lookupDyno @sym ?dyno

-- | A version of 'fromDyno' taking a default value in case the key is not
-- in the map.  When called on actual puzzle input, this is always 'id'.
-- However, for some test inputs, there might be supplied values.
--
-- Meant to be used with TypeApplications:
--
-- > fromDynoWith @"hello" 7
--
-- This is useful for when some problems have parameters that are
-- different with test inputs than for actual inputs.
fromDyno_
    :: forall (sym :: Symbol) a. (KnownSymbol sym, Typeable a, ?dyno :: DynoMap)
    => a            -- ^ default
    -> a
fromDyno_ def = lookupDynoWith @sym def ?dyno
