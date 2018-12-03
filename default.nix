{ mkDerivation, advent-of-code-api, aeson, ansi-terminal, astar
, base, bytestring, conduit, containers, criterion, curl
, data-default, data-default-class, data-memocombinators, deepseq
, directory, dlist, fgl, filepath, finite-typelits, foldl, free
, free-algebras, groups, hashable, haskeline, haskell-names
, haskell-src-exts, heredoc, hpack, lens, linear, megaparsec
, microlens, microlens-th, mtl, nonempty-containers
, optparse-applicative, pandoc, parallel, parsec
, parser-combinators, pointedlist, primitive, profunctors, psqueues
, pure-fft, recursion-schemes, semigroupoids, show-prettyprint
, singletons, split, statistics, stdenv, tagsoup, template-haskell
, text, these, time, transformers, unordered-containers, vector
, vector-sized, witherable, yaml
}:
mkDerivation {
  pname = "aoc2018";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    advent-of-code-api aeson ansi-terminal astar base bytestring
    conduit containers criterion curl data-default data-default-class
    data-memocombinators deepseq directory dlist fgl filepath
    finite-typelits foldl free free-algebras groups hashable haskeline
    haskell-names haskell-src-exts heredoc hpack lens linear megaparsec
    microlens-th mtl nonempty-containers pandoc parallel parsec
    parser-combinators pointedlist primitive profunctors psqueues
    pure-fft recursion-schemes semigroupoids show-prettyprint
    singletons split statistics tagsoup template-haskell text these
    time transformers unordered-containers vector vector-sized
    witherable yaml
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    ansi-terminal base containers deepseq finite-typelits lens
    microlens mtl optparse-applicative
  ];
  testHaskellDepends = [ ansi-terminal base mtl ];
  benchmarkHaskellDepends = [ base mtl ];
  preConfigure = "hpack";
  homepage = "https://github.com/mstksg/advent-of-code-2018#readme";
  description = "Advent of Code 2018 solutions and auto-runner";
  license = stdenv.lib.licenses.bsd3;
}
