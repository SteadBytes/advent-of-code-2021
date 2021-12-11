import aoc
import strutils, sequtils, sugar

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
  let grid = parseGrid(input)
  let riskLevels = collect:
    for c, v in grid.traverse():
      # I wish Nim iterators supported sequtils map/filter/all etc
      if grid.neighbours(c).toSeq().all(c => grid[c] > v):
        v + 1
  echo "part 1: ", riskLevels.foldl(a + b)
  #echo "part 2: "

when isMainModule:
  main()

