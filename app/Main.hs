{-# LANGUAGE ApplicativeDo   #-}
{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE LambdaCase      #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ViewPatterns    #-}

import           AOC2018
import           Control.Applicative
import           Control.DeepSeq
import           Control.Exception
import           Control.Monad
import           Criterion
import           Data.Char
import           Data.Finite
import           Data.List
import           Data.Maybe
import           Options.Applicative
import           Text.Printf
import           Text.Read
import qualified Data.Map            as M
import qualified System.Console.ANSI as ANSI

data TestSpec = TSAll
              | TSDayAll  { _tsDay  :: Finite 25 }
              | TSDayPart { _tsDay  :: Finite 25
                          , _tsPart :: Char
                          }
  deriving Show

data Opts = O { _oTestSpec :: TestSpec
              , _oTests    :: Bool
              , _oBench    :: Bool
              , _oLock     :: Bool
              , _oConfig   :: Maybe FilePath
              }

main :: IO ()
main = do
    O{..} <- execParser $ info (parseOpts <**> helper)
                ( fullDesc
               <> header "aoc2018 - Advent of Code 2018 challenge runner"
               <> progDesc ("Run challenges from Advent of Code 2018. Available days: " ++ availableDays)
                )
    Cfg{..} <- configFile $ fromMaybe "aoc-conf.yaml" _oConfig
    let toRun = case _oTestSpec of
          TSAll -> Right challengeMap
          TSDayAll d ->
            case M.lookup d challengeMap of
              Nothing -> Left  $ printf "Day not yet available: %d" (getFinite d + 1)
              Just cs -> Right $ M.singleton d cs
          TSDayPart d p -> do
            ps <- maybe (Left $ printf "Day not yet available: %d" (getFinite d + 1)) Right $
                    M.lookup d challengeMap
            c  <- maybe (Left $ printf "Part not found: %c" p) Right $
                    M.lookup p ps
            return $ M.singleton d (M.singleton p c)
    case toRun of
      Left e   -> putStrLn e
      Right cs -> flip (runAll _cfgSession _oLock) cs $ \c CD{..} -> do
        case _cdInp of
          Left err | not _oTests || _oBench -> do
            putStrLn "[ERROR]"
            mapM_ (putStrLn . ("  " ++)) err
          _ ->
            return ()
        when _oTests $ do
          testRes <- mapMaybe fst <$> mapM (uncurry (testCase True c)) _cdTests
          unless (null testRes) $ do
            let (mark, color)
                    | and testRes = ('✓', ANSI.Green)
                    | otherwise   = ('✗', ANSI.Red  )
            ANSI.setSGR [ ANSI.SetColor ANSI.Foreground ANSI.Vivid color ]
            printf "[%c] Passed %d out of %d test(s)\n"
                mark
                (length (filter id testRes))
                (length testRes)
            ANSI.setSGR [ ANSI.Reset ]
        when (_oTests || not _oBench) . forM_ _cdInp $ \inp ->
          testCase False c inp _cdAns

        when _oBench . forM_ _cdInp $ \inp ->
          benchmark (nf (runChallenge c) inp)
  where
    availableDays = intercalate ", "
                  . map (show . (+ 1) . getFinite)
                  . M.keys
                  $ challengeMap

runAll
    :: Maybe String
    -> Bool
    -> (Challenge -> ChallengeData -> IO ())
    -> ChallengeMap
    -> IO ()
runAll sess lock f = fmap void         $
                     M.traverseWithKey $ \d ->
                     M.traverseWithKey $ \p c -> do
    let CP{..} = challengePaths (CS d p)
    printf ">> Day %02d%c\n" (getFinite d + 1) p
    when lock $ do
      CD{..} <- challengeData sess (CS d p)
      forM_ _cdInp $ \inp ->
        mapM_ (writeFile _cpAnswer) =<< evaluate (force (runChallenge c inp))
    f c =<< challengeData sess (CS d p)

testCase
    :: Bool
    -> Challenge
    -> String
    -> Maybe String
    -> IO (Maybe Bool, Either ChallengeError String)
testCase emph c inp ans = do
    ANSI.setSGR [ ANSI.SetColor ANSI.Foreground ANSI.Vivid color ]
    printf "[%c]" mark
    ANSI.setSGR [ ANSI.Reset ]
    if emph
      then printf " (%s)\n" resStr
      else printf " %s\n"   resStr
    forM_ showAns $ \a -> do
      ANSI.setSGR [ ANSI.SetColor ANSI.Foreground ANSI.Vivid ANSI.Red ]
      printf "(Expected: %s)\n" a
      ANSI.setSGR [ ANSI.Reset ]
    return (status, res)
  where
    res = runChallenge c inp
    resStr = case res of
      Right r -> r
      Left CEParse -> "ERROR: No parse"
      Left CESolve -> "ERROR: No solution"
    (mark, showAns, status) = case ans of
      Just (strip->ex)    -> case res of
        Right (strip->r)
          | r == ex   -> ('✓', Nothing, Just True )
          | otherwise -> ('✗', Just ex, Just False)
        Left _        -> ('✗', Just ex, Just False)
      Nothing             -> ('?', Nothing, Nothing   )
    color = case status of
      Just True  -> ANSI.Green
      Just False -> ANSI.Red
      Nothing    -> ANSI.Blue

parseOpts :: Parser Opts
parseOpts = do
    d <- argument pDay ( metavar "DAY"
                      <> help "Day of challenge (1 - 25), or \"all\""
                       )
    p <- optional $ argument pPart ( metavar "PART"
                                  <> help "Challenge part (a, b, c, etc.)"
                                   )
    t <- switch $ long "tests"
               <> short 't'
               <> help "Run sample tests"
    b <- switch $ long "bench"
               <> short 'b'
               <> help "Run benchmarks"
    l <- switch $ long "lock"
               <> short 'l'
               <> help "Lock in results as \"correct\" answers"
    c <- optional $ strOption
        ( long "config"
       <> short 'c'
       <> metavar "PATH"
       <> help "Path to configuration file (default: aoc2018-conf.yaml)"
        )
    pure $ let ts = case d of
                      Just d' -> case p of
                        Just p' -> TSDayPart d' p'
                        Nothing -> TSDayAll  d'
                      Nothing -> TSAll
           in  O ts t b l c
  where
    pFin = eitherReader $ \s -> do
        n <- maybe (Left "Invalid day") Right $ readMaybe s
        maybe (Left "Day out of range") Right $ packFinite (n - 1)
    pDay = Nothing <$ maybeReader (guard . (== "all") . map toLower)
       <|>    Just <$> pFin
    pPart = eitherReader $ \case
        []  -> Left "No part"
        [p] | isAlpha p -> Right (toLower p)
            | otherwise -> Left "Invalid part (not an alphabet letter)"
        _   -> Left "Invalid part (not a single alphabet letter)"
