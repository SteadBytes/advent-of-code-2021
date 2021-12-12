import aoc
import sequtils, sugar, deques, sets

proc main() =
  const input = staticRead("../inputs/d09.txt")
  let grid = parseGrid(input)
  let lowPoints = collect:
    for c in grid.traverse():
      # I wish Nim iterators supported sequtils map/filter/all etc
      if grid.neighbours(c).toSeq().all(c2 => grid[c2] > grid[c]):
        c

  echo "part 1: ", lowPoints.map(c => grid[c] + 1).foldl(a + b)

  # A basin consists of all locations contained within a border of risk level 9
  # locations or the edge of the grid, with a low point in the centre.  Find
  # points within each basin with a BFS outwards from each low point until a 9
  # or edge is reached.

  # Since only the top 3 sizes are needed, a simple linear sort on each
  # iteration is sufficient (as opposed to e.g. a max heap)
  var topSizes: array[3, int] = [0, 0, 0]
  for lp in lowPoints:
    # Include starting low point in size
    var size = 1

    # BFS
    var q = [lp].toDeque()
    var visited = toHashSet([lp])
    while q.len > 0:
      let c = q.popFirst()
      for c2 in grid.neighbours(c):
        if not (c2 in visited or grid[c2] == 9):
          inc size
          visited.incl(c2)
          q.addLast(c2)

    # Update top 3 largest sizes if necessary
    for i in 0..<topsizes.len:
      # New top 3 largest size found
      if topSizes[i] < size:
        if i == topSizes.len - 1:
          topSizes[i] = size
        else:
          # Right shift `i+1...` elements (dropping last element) and insert
          # new size at `i`
          topSizes[^1] = topSizes[^2]
          let tmp = topSizes[i]
          topSizes[i] = size
          topSizes[i + 1] = tmp
        break

  echo "part 2: ", topSizes.foldl(a * b)

when isMainModule:
  main()

