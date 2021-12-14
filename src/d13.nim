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

func doFold(dots: HashSet[Coord], fold: Coord): HashSet[Coord] =
  collect:
    for c in dots:
      {abs(fold - abs(fold-c))}

proc main() =
  const input = staticRead("../inputs/d13.txt")
  let (dots, instructions) = parseInput(input)
  echo "part 1: ", doFold(dots, instructions[0]).len

  # TODO: This is not the most elegant code I've ever written but it works...
  let finalDots = instructions.foldl(doFold(a, b), dots).toSeq()
  let xRange = finalDots.map(c => c.x).min..finalDots.map(c => c.x).max
  let yRange = finalDots.map(c => c.x).min..finalDots.map(c => c.y).max
  var s = ""
  for y in yRange:
    s &= '\n'
    for x in xRange:
      if (x, y) in finalDots:
        s &= "#"
      else:
        s &= " "
  echo "part 2: ", s

when isMainModule:
  main()

