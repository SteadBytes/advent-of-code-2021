import aoc
import sequtils, sugar, heapqueue, tables, sets

proc main() =
  const input = staticRead("../inputs/d15.txt")
  let grid = parseGrid(input)
  let
    start = (0, 0)
    target = (grid.width-1, grid.height-1)

  var dist = {start: 0}.toTable()
  var visited = [start].toHashSet()
  var queue = {0: start}.toHeapQueue()

  while queue.len > 0:
    let (_, v) = queue.pop()
    if v == target:
      echo "part 1: ", dist[target]
      break
    visited.incl(v)
    for u in grid.neighbours(v).toSeq.filter(u => not visited.contains(u)):
      let risk = dist[v] + grid[u]
      if risk < dist.getOrDefault(u, high int):
        dist[u] = risk
        queue.push((risk, u))

  #echo "part 2: "

when isMainModule:
  main()

