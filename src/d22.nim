import aoc
import strutils, sequtils, sugar, strscans, sets

# TODO: Share with d19?
type
  Coord3D = (int, int, int)
  Rule = (bool, Coord3D, Coord3D)

template x(c: Coord3D): int = c[0]
template y(c: Coord3D): int = c[1]
template z(c: Coord3D): int = c[2]

func parseRule(s: string): Rule =
  let parts = s.split(" ")
  assert parts.len == 2
  let on =
    case parts[0]:
      of "on": true
      of "off": false
      else: unreachable()
  let (ok, x1, x2, y1, y2, z1, z2) = scanTuple(parts[1], "x=$i..$i,y=$i..$i,z=$i..$i")
  assert ok
  (on, (x1, y1, z1), (x2, y2, z2))

func parseInput(s: string): seq[Rule] =
  s.strip().splitLines.map(parseRule)

proc part1(rebootSteps: seq[Rule]): int =
  var onCubes: HashSet[Coord3D]
  for (on, c1, c2) in rebootSteps:
    let targets = collect:
      for x in max(-50, c1.x)..min(50, c2.x):
        for y in max(-50, c1.y)..min(50, c2.y):
          for z in max(-50, c1.z)..min(50, c2.z):
            {(x, y, z)}
    if on:
      onCubes.incl(targets)
    else:
      onCubes.excl(targets)
  onCubes.len

proc main() =
  const input = staticRead("../inputs/d22.txt")
  let rebootSteps = parseInput(input)

  echo "part 1: ", part1(rebootSteps)

when isMainModule:
  when defined(testing):
    import unittest


    test "part 1":
      const input = staticRead("../inputs/d22.example.txt")
      let rebootSteps = parseInput(input)
      check part1(rebootSteps) == 590784

  else:
    main()

