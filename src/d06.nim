import strutils, sequtils, algorithm

proc countFish(ages: seq[int], days: int): int =
  # Mapping from timer value to number of fish with that timer value
  var timerCounts: array[0..8, int]
  for x in ages:
    timerCounts[x].inc
  # Each day, the number of fish for each timer value "shifts left":
  # - The timer for each fish with timer values [1..8] decrements
  # - Timer value 8 takes on the value of timer 0 to represent the new fish -
  # - Timer value 6 increases by timer value 0 to account for the parents of the
  #   new fish (now restarting their cycle)
  for _ in 0..<days:
    timerCounts.rotateLeft(1)
    timerCounts[6] += timerCounts[8]
  timerCounts.foldl(a + b)

proc main() =
  const input = staticRead("../inputs/d06.txt")
  let ages = input.strip().split(",").map(parseInt)
  echo "part 1: ", countFish(ages, 80)
  echo "part 2: ", countFish(ages, 256)

when isMainModule:
  main()

