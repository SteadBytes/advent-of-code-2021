import aoc
import strutils, sequtils, strscans, sets, sugar

func parseCoord(s: string): Coord =
  let (ok, x, y) = s.scanTuple("$i,$i")
  assert ok
  (x, y)

func parseInstruction(s: string): Coord =
  let (ok, axis, n) = s.scanTuple("fold along $c=$i")
  assert ok
  case axis:
    of 'x':
      (n, 0)
    of 'y':
      (0, n)
    else:
      unreachable()

func parseInput(s: string): (HashSet[Coord], seq[Coord]) =
  let sections = s.strip().split("\n\n")
  assert sections.len == 2
  let dots = sections[0].splitLines().map(parseCoord).toHashSet()
  let instructions = sections[1].splitLines().map(parseInstruction)
  (dots, instructions)

proc main() =
  const input = staticRead("../inputs/d13.txt")
  let (dots, instructions) = parseInput(input)
  let fold = instructions[0]
  let foldedDots = collect:
    for c in dots:
      {abs(fold - abs(fold-c))}
  echo "part 1: ", foldedDots.len
  #echo "part 2: "

when isMainModule:
  main()

