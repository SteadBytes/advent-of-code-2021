import aoc
import sequtils, sugar

proc step(g: var Grid): int =
  # Queue of locations to check for flashes - initially all locations
  var queue = g.traverse().toSeq()
  # Increase energy levels of each octopus by 1
  for c in queue:
    inc g[c]
  while queue.len > 0:
    let c = queue.pop()
    # Any octopus with an energy level > 9 flashes
    if g[c] >= 10:
      # Energy level set to 0 after a flash
      g[c] = 0
      inc result
      # Increase energy level of each adjacent (including diagonal) octopus by
      # 1 if it hasn't already flashed in this step
      for c2 in g.neighbours(c, directions = directions8):
        # Skip already flashed
        if g[c2] == 0:
          continue
        inc g[c2]
        queue.add(c2)

proc part1(g: Grid): int =
  var g = g
  for _ in 0..<100:
    result += step(g)

proc main() =
  const input = staticRead("../inputs/d11.txt")
  var grid = parseGrid(input, x => int8(parseDigit(x)))
  echo "part 1: ", part1(grid)
  #echo "part 2: "

when isMainModule:
  main()

