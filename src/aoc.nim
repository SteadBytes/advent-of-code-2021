import strutils, sequtils, options, sugar, tables

# Puzzle input parsing

proc readInputInts*(path: string): seq[int] {.compiletime.} =
  ## Compile-time parse an integer per line from puzzle input at `path`.
  return staticRead(path).strip().splitLines().map(parseInt)

# Grids/Coordinates

type
  Coord* = (int, int)
  Grid*[T] = seq[seq[T]]

template x*(c: Coord): int = c[0]

template y*(c: Coord): int = c[1]

template `+`*(a, b: Coord): Coord = (a.x + b.x, a.y + b.y)
template `-`*(a, b: Coord): Coord = (a.x - b.x, a.y - b.y)

func abs*(c: Coord): Coord =
  (abs(c.x), abs(c.y))

template `[]`*[T](g: Grid[T], index: Coord): T =
  g[index.y][index.x]

proc `[]=`*[T](g: var Grid[T], index: Coord, val: T) =
  g[index.y][index.x] = val

iterator traverse*[T](g: Grid[T]): Coord =
  ## Walk `g` from top left to bottom right, yielding coordinates and corresponding values.
  for y, row in g:
    for x, _ in row:
      yield (x, y)

## Cardinal directions (N, E, S, W), assuming top left origin.
const directions4* = [(0, -1), (1, 0), (0, 1), (-1, 0)]
## Cardinal and intercardinal directions (N, NE, E, SE, S, SW, W, NW), assuming top left origin.
const directions8* = [
  (0, -1),
  (1, -1),
  (1, 0),
  (1, 1),
  (0, 1),
  (-1, 1),
  (-1, 0),
  (-1, -1),
]

iterator neighbours*(c: Coord, directions: openArray[
  ## Yields coordinates adjacent to `c`.
    Coord] = directions4): Coord =
  for d in directions:
    yield d + c

iterator neighbours*(g: Grid, c: Coord, directions: openArray[
  ## Yields coordinates adjacent to `c` within the bounds of `g`.
    Coord] = directions4): Coord =
  let yLim = g.len
  let xLim = g[0].len
  for (x, y) in neighbours(c, directions):
    if 0 <= x and x < xLim and 0 <= y and y < yLim:
      yield (x, y)

func parseDigit*(c: char): int =
  result = int(c) - int('0')
  if not result in 0..9:
    raise newException(ValueError, "invalid digit: " & c)

func parseGrid*[T](s: string; f: proc (x: char): T): Grid[T] =
  result = s.strip().splitLines().map(l => l.map(f))
  # Sanity check consistent width
  let l = result[0].len
  assert result.allIt(it.len == l)

func parseGrid*(s: string): Grid[int] =
  parseGrid(s, parseDigit)

# `Option` utilities

proc filterMap*[T, S](s: openArray[T]; f: proc (x: T): Option[S]): seq[S] =
  s.map(f).filter(x => x.isSome).map(x => x.get())

proc get*[A, B](t: Table[A, B]; key: A): Option[B] =
  if t.hasKey(key):
    some(t[key])
  else:
    none(B)

# Misc

template unreachable*(): untyped =
  raise newException(Exception, "internal error: entered unreachable code")
