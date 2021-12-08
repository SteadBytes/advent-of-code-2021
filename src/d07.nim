import strutils, sequtils, sugar, math

proc main() =
   const input = staticRead("../inputs/d07.txt")
   let positions = input.strip().split(",").map(parseInt)
   let distances = (0..positions.max()).mapIt(positions.map(x => abs(it - x)))
   echo "part 1: ", distances.mapIt(it.sum()).min()
   echo "part 2: ", distances.mapIt(it.map(x => x * (x + 1) div 2).sum()).min()

when isMainModule:
   main()

