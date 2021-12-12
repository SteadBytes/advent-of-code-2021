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

template `[]`*[T](data: Grid[T], index: Coord): T =
  data[index.y][index.x]

## Walk `g` from top left to bottom right, yielding coordinates and corresponding values.
iterator traverse*[T](g: Grid[T]): Coord =
  for y, row in g:
    for x, _ in row:
      yield (x, y)

## North, East, South, West (assuming top left origin).
const directions* = [(0, -1), (1, 0), (0, 1), (-1, 0)]

## Yields coordinates adjacent to `c` (North, East, South, West).
iterator neighbours*(c: Coord): Coord =
  for d in directions:
    yield d + c

## Yields coordinates adjacent to `c` within the bounds of `g`.
iterator neighbours*(g: Grid, c: Coord): Coord =
  let yLim = g.len
  let xLim = g[0].len
  for (x, y) in neighbours(c):
    if 0 <= x and x < xLim and 0 <= y and y < yLim:
      yield (x, y)

func parseGrid*(s: string): Grid[int] =
  result = s.strip().splitLines().map(l => l.map(x => int(x) - int('0')))
  # Sanity check consistent width
  let l = result[0].len
  assert result.allIt(it.len == l)

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
