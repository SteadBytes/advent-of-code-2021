import aoc
import sequtils, sugar, heapqueue, tables, sets

func findMinRiskPath(g: Grid[int]): int =
  ## Dijkstra's Algorithm to find the shortest path using "risk level" as
  ## cost/distance.
  let
    start = (0, 0)
    target = (g.width-1, g.height-1)

  var
    dist = {start: 0}.toTable()
    visited = [start].toHashSet()
    queue = {0: start}.toHeapQueue()

  while queue.len > 0:
    let (_, v) = queue.pop()
    if v == target:
      return dist[target]
    visited.incl(v)
    for u in g.neighbours(v).toSeq.filter(u => not visited.contains(u)):
      let risk = dist[v] + g[u]
      if risk < dist.getOrDefault(u, high int):
        dist[u] = risk
        queue.push((risk, u))

proc main() =
  const input = staticRead("../inputs/d15.txt")
  let grid = parseGrid(input)

  echo "part 1: ", findMinRiskPath(grid)

  let
    gridFactor = 5
    maxRisk = 9
    repeats = (0..<gridFactor).toSeq()
    fullGrid = repeats.map(
      yRep => grid.map(
        row => repeats.map(
          xRep => row.map(
            # Wrap risk value into range 1..9
            # The `maxRisk - 1` and `mod maxRisk + 1` terms ensures that risk
            # values 1..8 are unchanged, whilst 9 is wrapped to 1
            risk => (risk + yRep + xRep + maxRisk - 1) mod maxRisk + 1)
        ).concat()
      )
    ).concat()

  echo "part 2: ", findMinRiskPath(fullGrid)

when isMainModule:
  main()

