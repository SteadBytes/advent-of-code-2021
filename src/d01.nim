import aoc

func countIncreases(depths: seq[int]): int = 
  var prev = 0
  for (i, x) in depths.pairs:
    if i != 0 and x > prev:
      inc result
    prev = x

let depths = readIntLines("inputs/d01.txt")
echo countIncreases(depths)
