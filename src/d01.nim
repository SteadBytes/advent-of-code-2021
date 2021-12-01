import aoc
import sequtils, sugar

func countIncreases(depths: seq[int], n: int): int =
  zip(depths, depths[n..^1]).filter(x => x[1] > x[0]).len

const depths = readInputInts("../inputs/d01.txt")

echo "part 1: ", countIncreases(depths, 1)
echo "part 2: ", countIncreases(depths, 3)
