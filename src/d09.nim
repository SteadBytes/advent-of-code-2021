import strutils, sequtils, sugar, deques, sets

# TODO: Move into aoc module (grids/coords are common in AoC)

type Coord = (int, int)

template x(c: Coord): int = c[0]

template y(c: Coord): int = c[1]

template `+`*(a, b: Coord): Coord = (a.x + b.x, a.y + b.y)

type Grid[T] = seq[seq[T]]

template `[]`*[T](data: Grid[T], index: Coord): T =
  data[index.y][index.x]

## Walk `g` from top left to bottom right, yielding coordinates and corresponding values.
iterator traverse[T](g: Grid[T]): Coord =
  for y, row in g:
    for x, _ in row:
      yield (x, y)

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

