import aoc

func countIncreases(depths: seq[int], n: int): int = 
  for i in n..<depths.len:
    if depths[i] > depths[i-n]:
      inc result

let depths = readIntLines("inputs/d01.txt")
echo "part 1: ", countIncreases(depths, 1)
echo "part 2: ", countIncreases(depths, 3)
