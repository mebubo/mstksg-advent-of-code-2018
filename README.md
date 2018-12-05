Advent of Code 2018
===================

It's the most wonderful time of the year!

My [Advent of Code 2018][aoc2018] Haskell solutions here, along with an automated
fetching, testing, running environment.

Check out reflections and commentary at the [package haddocks][haddock]!
(individual links down below)

[aoc2018]: https://adventofcode.com/2018
[haddock]: https://mstksg.github.io/advent-of-code-2018/

Reflections and Benchmarks
--------------------------

*   **[Day 1 Reflections][d01r]** *[code][d01g]* / *[rendered][d01h]* / *[benchmarks][d01b]*
*   **[Day 2 Reflections][d02r]** *[code][d02g]* / *[rendered][d02h]* / *[benchmarks][d02b]*
*   **[Day 3 Reflections][d03r]** *[code][d03g]* / *[rendered][d03h]* / *[benchmarks][d03b]*
*   **[Day 4 Reflections][d04r]** *[code][d04g]* / *[rendered][d04h]* / *[benchmarks][d04b]*
*   **[Day 5 Reflections][d05r]** *[code][d05g]* / *[rendered][d05h]* / *[benchmarks][d05b]*

"Rendered" links go to haddock source renders for code, with reflections in the
documentation.  Haddock source renders have hyperlinked identifiers,
so you can follow any unrecognized identifiers to see where I have defined them
in the library.

### `:~>` type

If you're looking at my actual github solutions, you'll notice thattThis year
I'm implementing my solutions in terms of a `:~>` record type:

```haskell
data a :~> b = MkSol
    { sParse :: String -> Maybe a    -- ^ parse input into an `a`
    , sSolve :: a      -> Maybe b    -- ^ solve an `a` input to a `b` solution
    , sShow  :: b      -> String     -- ^ print out the `b` solution for submission
    }
```

An `a :~> b` is a solution to a challenge expecting input of type `a` and
producing answers of type `b`.  It also packs in functions to parse a `String`
into an `a`, and functions to show a `b` as a `String` to submit as an answer.

This helps me mentally separate out parsing, solving, and showing, allowing for
some cleaner code and an easier time planning my solution.

Such a challenge can be "run" on string inputs by feeding the string into
`sParse`, then `sSolve`, then `sShow`:

```haskell
-- | Run a ':~>' on some input, retuning 'Maybe'
runSolution :: Challenge -> String -> Maybe String
runSolution MkSol{..} s = do
    x <- sParse s
    y <- sSolve x
    pure $ sShow y
```

In the actual library, I have `runSolution` return an `Either` so I can debug
which stage the error happened in.

Interactive
-----------

The *[AOC2018.Run.Interactive][interactive]* module has code for testing
your solutions and submitting within GHCI, so you don't have to re-compile.
If you edit your solution programs, they are automatically updated when you hit
`:r` in ghci.

[interactive]: https://mstksg.github.io/advent-of-code-2018/AOC2018-Run-Interactive.html

```haskell
ghci> execSolution_   $ mkCS 2 'a'  -- get answer for challenge based on solution
ghci> testSolution_   $ mkCS 2 'a'  -- run solution against test suite
ghci> viewPrompt_     $ mkCS 2 'a'  -- view the prompt for a part
ghci> waitForPrompt_  $ mkCS 2 'a'  -- count down to the prompt for a part
ghci> submitSolution_ $ mkCS 2 'a'  -- submit a solution
```

These are loaded with session key stored in the configuration file (see next
section).

Executable
----------

Comes with test examples given in problems.

You can install using `stack`:

```bash
$ git clone https://github.com/mstksg/advent-of-code-2018
$ cd advent-of-code-2018
$ stack setup
$ stack install
```

The executable `aoc2018` includes a testing and benchmark suite, as well as a
way to view prompts within the command line:

```
$ aoc2018 --help
aoc2018 - Advent of Code 2018 challenge runner

Usage: aoc2018 [-c|--config PATH] COMMAND
  Run challenges from Advent of Code 2018. Available days: 1, 2, 3 (..)

Available options:
  -c,--config PATH         Path to configuration file (default: aoc-conf.yaml)
  -h,--help                Show this help text

Available commands:
  run                      Run, test, and benchmark challenges
  view                     View a prompt for a given challenge
  submit                   Test and submit answers for challenges
  test                     Alias for run --test
  bench                    Alias for run --bench
  countdown                Alias for view --countdown

$ aoc2018 run 3 b
>> Day 03b
>> [✓] 243
```

You can supply input via stdin with `--stdin`:

```
$ aoc2018 run 1 --stdin
>> Day 01a
+1
+2
+1
-3
<Ctrl+D>
[?] 1
>> Day 01b
[?] 1
```

Benchmarking is implemented using *criterion*

```
$ aoc2018 bench 2
>> Day 02a
benchmarking...
time                 1.317 ms   (1.271 ms .. 1.392 ms)
                     0.982 R²   (0.966 R² .. 0.999 R²)
mean                 1.324 ms   (1.298 ms .. 1.373 ms)
std dev              115.5 μs   (77.34 μs .. 189.0 μs)
variance introduced by outliers: 65% (severely inflated)

>> Day 02b
benchmarking...
time                 69.61 ms   (68.29 ms .. 72.09 ms)
                     0.998 R²   (0.996 R² .. 1.000 R²)
mean                 69.08 ms   (68.47 ms .. 69.99 ms)
std dev              1.327 ms   (840.8 μs .. 1.835 ms)
```

Test suites run the example problems given in the puzzle description, and
outputs are colorized in ANSI terminals.

```
$ aoc2018 test 1
>> Day 01a
[✓] (3)
[✓] (3)
[✓] (0)
[✓] (-6)
[✓] Passed 4 out of 4 test(s)
[✓] 416
>> Day 01b
[✓] (2)
[✓] (0)
[✓] (10)
[✓] (5)
[✓] (14)
[✓] Passed 5 out of 5 test(s)
[✓] 56752
```

This should only work if you're running `aoc2018` in the project directory.

**To run on actual inputs**, the executable expects inputs to be found in the
folder `data/XX.txt` in the directory you are running in.  That is, the input
for Day 7 will be expected at `data/07.txt`.

*aoc2018 will download missing input files*, but requires a session token.
This can be provided in `aoc-conf.yaml`:

```yaml
session:  [[ session token goes here ]]
```

Session keys are also required to download "Part 2" prompts for each challenge.

You can "lock in" your current answers (telling the executable that those are
the correct answers) by passing in `--lock`.  This will lock in any final
puzzle solutions encountered as the verified official answers.  Later, if you
edit or modify your solutions, they will be checked on the locked-in answers.

These are stored in `data/ans/XXpart.txt`.  That is, the target output for Day 7
(Part 2, `b`) will be expected at `data/ans/07b.txt`.  You can also manually
edit these files.

You can view prompts: (use `--countdown` to count down until a prompt is
released, and display immediately)

```
$ aoc2018 view 3 b
>> Day 03b
--- Part Two ---
----------------

Amidst the chaos, you notice that exactly one claim doesn't overlap by
even a single square inch of fabric with any other claim. If you can
somehow draw attention to it, maybe the Elves will be able to make
Santa's suit after all!

For example, in the claims above, only claim `3` is intact after all
claims are made.

*What is the ID of the only claim that doesn't overlap?*
```

You can also submit answers:

```
$ aoc2018 submit 1 a
```

Submissions will automatically run the test suite.  If any tests fail, you will
be asked to confirm submission or else abort.  The submit command will output
the result of your submission: The message from the AoC website, and whether or
not your answer was correct (or invalid or ignored).  Answers that are
confirmed correct will be locked in and saved for future testing against, in
case you change your solution.

[d01g]: https://github.com/mstksg/advent-of-code-2018/blob/master/src/AOC2018/Challenge/Day01.hs
[d01h]: https://mstksg.github.io/advent-of-code-2018/src/AOC2018.Challenge.Day01.html
[d01r]: https://github.com/mstksg/advent-of-code-2018/blob/master/reflections.md#day-1
[d01b]: https://github.com/mstksg/advent-of-code-2018/blob/master/reflections.md#day-1-benchmarks

[d02g]: https://github.com/mstksg/advent-of-code-2018/blob/master/src/AOC2018/Challenge/Day02.hs
[d02h]: https://mstksg.github.io/advent-of-code-2018/src/AOC2018.Challenge.Day02.html
[d02r]: https://github.com/mstksg/advent-of-code-2018/blob/master/reflections.md#day-2
[d02b]: https://github.com/mstksg/advent-of-code-2018/blob/master/reflections.md#day-2-benchmarks

[d03g]: https://github.com/mstksg/advent-of-code-2018/blob/master/src/AOC2018/Challenge/Day03.hs
[d03h]: https://mstksg.github.io/advent-of-code-2018/src/AOC2018.Challenge.Day03.html
[d03r]: https://github.com/mstksg/advent-of-code-2018/blob/master/reflections.md#day-3
[d03b]: https://github.com/mstksg/advent-of-code-2018/blob/master/reflections.md#day-3-benchmarks

[d04g]: https://github.com/mstksg/advent-of-code-2018/blob/master/src/AOC2018/Challenge/Day04.hs
[d04h]: https://mstksg.github.io/advent-of-code-2018/src/AOC2018.Challenge.Day04.html
[d04r]: https://github.com/mstksg/advent-of-code-2018/blob/master/reflections.md#day-4
[d04b]: https://github.com/mstksg/advent-of-code-2018/blob/master/reflections.md#day-4-benchmarks

[d05g]: https://github.com/mstksg/advent-of-code-2018/blob/master/src/AOC2018/Challenge/Day05.hs
[d05h]: https://mstksg.github.io/advent-of-code-2018/src/AOC2018.Challenge.Day05.html
[d05r]: https://github.com/mstksg/advent-of-code-2018/blob/master/reflections.md#day-5
[d05b]: https://github.com/mstksg/advent-of-code-2018/blob/master/reflections.md#day-5-benchmarks
