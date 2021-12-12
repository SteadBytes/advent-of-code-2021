import aoc
import strutils, sequtils, sugar, deques, sets, algorithm

# TODO: Move into aoc module (grids/coords are common in AoC)

type Coord = (int, int)

template x(c: Coord): int = c[0]

template y(c: Coord): int = c[1]

template `+`*(a, b: Coord): Coord = (a.x + b.x, a.y + b.y)

type Grid[T] = seq[seq[T]]

template `[]`*[T](data: Grid[T], index: Coord): T =
  data[index.y][index.x]

proc `[]=`*[T](data: var Grid[T], index: Coord, val: int) =
  data[index.y][index.x] = val

## Walk `g` from top left to bottom right, yielding coordinates and corresponding values.
iterator traverse[T](g: Grid[T]): (Coord, T) =
  for y, row in g:
    for x, v in row:
      yield ((x, y), v)

## North, East, South, West (assuming top left origin).
const directions = [(0, -1), (1, 0), (0, 1), (-1, 0)]

## Yields coordinates adjacent to `c` (North, East, South, West).
iterator neighbours(c: Coord): Coord =
  for d in directions:
    yield d + c

## Yields coordinates adjacent to `c` within the bounds of `g`.
iterator neighbours(g: Grid, c: Coord): Coord =
  let yLim = g.len
  let xLim = g[0].len
  for (x, y) in neighbours(c):
    if 0 <= x and x < xLim and 0 <= y and y < yLim:
      yield (x, y)

func parseGrid(s: string): Grid[int] =
  result = s.strip().splitLines().map(l => l.map(x => int(x) - int('0')))
  # Sanity check consistent width
  let l = result[0].len
  assert result.allIt(it.len == l)

proc main() =
  const input = staticRead("../inputs/d09.txt")
# const input = staticRead("../inputs/d09.example.txt")
  let grid = parseGrid(input)
  let lowPointRiskLevels = collect:
    for c, v in grid.traverse():
      # I wish Nim iterators supported sequtils map/filter/all etc
      if grid.neighbours(c).toSeq().all(c => grid[c] > v):
        v + 1
  echo "part 1: ", lowPointRiskLevels.foldl(a + b)

  # A basin consists of all locations contained within a border of risk level 9
  # locations or the edge of the grid, with a low point in the centre.
  # Search outwards from each low point until a 9 or edge is reached.

  # TODO: part 1 duplication
  let lowPoints = collect:
    for c, v in grid.traverse():
      # I wish Nim iterators supported sequtils map/filter/all etc
      if grid.neighbours(c).toSeq().all(c => grid[c] > v):
        c
  var basinSizes = newSeq[int](lowPoints.len)
  for lp in lowPoints:
    # Include starting low point in size
    var size = 1
    var q = [lp].toDeque()
    var visited = toHashSet([lp])
    while q.len > 0:
      let c = q.popFirst()
      for c2 in grid.neighbours(c):
        if not (c2 in visited or grid[c2] == 9):
          inc size
          visited.incl(c2)
          q.addLast(c2)
    basinSizes.add(size)

  basinSizes.sort(order = SortOrder.Descending)
  echo "part 2: ", basinSizes[0..<3].foldl(a * b)

when isMainModule:
  main()

