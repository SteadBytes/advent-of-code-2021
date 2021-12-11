import strutils, sequtils

proc readInputInts*(path: string): seq[int] {.compiletime.} =
  ## Compile-time parse an integer per line from puzzle input at `path`.
  return staticRead(path).strip().splitLines().map(parseInt)

template unreachable*(): untyped =
  raise newException(Exception, "internal error: entered unreachable code")
