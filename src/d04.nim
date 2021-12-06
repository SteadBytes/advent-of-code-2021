{.experimental: "caseStmtMacros".}
import strutils, sequtils, sugar, tables, options, fusion/matching


# Since the chosen numbers are provided up front, the winning board can be
# deduced without turn-by-turn simulation of the game:
# - The list of chosen numbers provide a mapping from number -> turn
# - The turn at which a row/column is completed is the maximum value given by
#   the number -> turn mapping for the numbers in that row/column
# - The first row/column to be completed for a given board is the minimum completion turn for all it's rows/columns
# - The winning board is the board with the minimum turn for fist row/column completion
#
# The unmarked values for the winning board are those with a corresponding turn
# greater than the winning turn.

# TODO: move these to utils
proc filterMap[T](s: openArray[T]; f: proc (x: T): Option[T]): seq[T] =
  s.map(f).filter(x => x.isSome).map(x => x.get())

proc get[A, B](t: Table[A, B]; key: A): Option[B] =
  if t.hasKey(key):
    some(t[key])
  else:
    none(B)

# TODO: Remove most of the `Option`s throughout this solution. These are mostly
# present to account for numbers on boards that aren't in the list of numbers.
# However, it *seems* (at least for my inputs) that all the numbers on the
# boards are present in the list of numbers (e.g. by the end of the list, all
# boards will be completely marked). Removing the `Option` handling will make
# much of this solution clearer and more concise.

proc winningTurn(turnsMap: Table[int, int]; board: seq[seq[int]]): Option[int] =
  let turns = board.map(l => l.filterMap(x => turnsMap.get(x)))
  let rows = turns.filter(r => r.len == 5)
  let rowWin = if rows.len > 0: some(rows.map(r => r.max).min) else: none(int)
  let cols = collect:
    for i in 0..rows.len-1:
      rows.map(r => r[i])
  let colWin = if cols.len > 0: some(cols.map(c => c.max).min) else: none(int)
  result = case (rowWin, colWin):
    of (Some(@a), Some(@b)): some(min(a, b))
    of (Some(@a), None()): some(a)
    of (None(), Some(@b)): some(b)
    else: none(int)

proc score(
  board: seq[seq[int]];
  numbers: seq[int];
  turnsMap: Table[int, int];
  finalTurn: int;
): int =
  let finalNumber = numbers[finalTurn]
  let unmarkedSum =
    board
      .map(l => l.map(x => (
        if turnsMap.getOrDefault(x, high int) <= finalTurn:
        0
      else:
        x
      )).foldl(a + b))
      .foldl(a + b)
  unmarkedSum * finalNumber

proc main() =
  const input = staticRead("../inputs/d04.txt")

  let sections = input.split("\n\n")
  let numbers = sections[0].split(",").map(parseInt)
  # I _wish_ iterators were more composable e.g. numbers.pairs.map(x => (x[1], x[0]))
  let turnsMap = collect:
    for i, x in numbers: {x: i}
  # TODO: Use arrays here as we know each board is 5x5?
  let boards = sections[1..^1].map(
      s => s.strip().splitLines().map(l => l.splitWhitespace().map(parseInt))
  )
  assert boards.all(b => b.all(r => r.map(x => turnsMap.hasKey(x)).all(x => x == true)))

  let winTurns = boards.map(b => winningTurn(turnsMap, b))
  let firstWin = winTurns.map(x => x.get(high int)).minIndex()
  let lastWin = winTurns.map(x => x.get(low int)).maxIndex()

  # Sanity check
  assert winTurns[firstWin].isSome
  assert winTurns[lastWin].isSome

  let firstScore = score(
    boards[firstWin],
    numbers,
    turnsMap,
    winTurns[firstWin].get()
  )
  let lastScore = score(
    boards[lastWin],
    numbers,
    turnsMap,
    winTurns[lastWin].get()
  )
  echo "part 1: ", firstScore
  echo "part 2: ", lastScore

when isMainModule:
  main()

