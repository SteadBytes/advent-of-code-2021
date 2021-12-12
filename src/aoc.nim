import strutils, sequtils, options, sugar, tables

# Puzzle input parsing

proc readInputInts*(path: string): seq[int] {.compiletime.} =
  ## Compile-time parse an integer per line from puzzle input at `path`.
  return staticRead(path).strip().splitLines().map(parseInt)

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
