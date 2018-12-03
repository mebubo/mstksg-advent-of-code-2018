let pkgs = import <nixpkgs> {};

in

  {
    adventOfCode2018 = pkgs.haskell.packages.ghc863.callPackage ./default.nix { };
  }
