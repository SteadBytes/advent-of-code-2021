import aoc
import strutils, sequtils, sugar, strscans, sets, Options, macros

# TODO: Share with d19?
type
  Coord3D = (int, int, int)
  Cuboid = tuple[lb: Coord3D, ub: Coord3D]
  RebootStep = tuple[on: bool, bounds: Cuboid]

template x(c: Coord3D): int = c[0]
template y(c: Coord3D): int = c[1]
template z(c: Coord3D): int = c[2]

func volume(r: RebootStep): int =
  let (lb, ub) = r.bounds
  (if r.on: 1 else: -1) * (ub.x - lb.x + 1) * (ub.y - lb.y + 1) * (ub.z - lb.z + 1)

func intersection(x, y: Slice[int]): Option[Slice[int]] =
  let z = max(x.a, y.a)..min(x.b, y.b)
  if z.a <= z.b:
    result = some(z)

func intersection(a, b: Cuboid): Option[Cuboid] =
  # Nim's `Option` utilities are limited in comparison to Rust :/
  intersection(a.lb.x..a.ub.x, b.lb.x..b.ub.x)
  .map(x => intersection(a.lb.y..a.ub.y, b.lb.y..b.ub.y)
    .map(y => intersection(a.lb.z..a.ub.z, b.lb.z..b.ub.z)
      .map(z => (lb: (x.a, y.a, z.a), ub: (x.b, y.b, z.b)))
    )
  ).flatten.flatten

func parseRule(s: string): RebootStep =
  let parts = s.split(" ")
  assert parts.len == 2
  let on =
    case parts[0]:
      of "on": true
      of "off": false
      else: unreachable()
  let (ok, x1, x2, y1, y2, z1, z2) = scanTuple(parts[1], "x=$i..$i,y=$i..$i,z=$i..$i")
  assert ok
  (on: on, bounds: (lb: (x1, y1, z1), ub: (x2, y2, z2)))

func parseInput(s: string): seq[RebootStep] =
  s.strip().splitLines.map(parseRule)

proc part1(steps: seq[RebootStep]): int =
  var onCubes: HashSet[Coord3D]
  for (on, bounds) in steps:
    let (c1, c2) = bounds
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

# TODO: This ought to also be used for part 1 (just add the initialisation region restriction)
proc part2(steps: seq[RebootStep]): int =
  ## Part 1's naive implementation will fail here due to the increased search space.
  ##
  ## Idea: Treat "on" steps as having a positive volume and "off" steps as
  ## having a negative volume. The sum of the ordered intersection of these
  ## volumes is the number of cubes that are on after applying all of the
  ## rules.
  ##
  ## 1. Initialise an empty cuboid list
  ## 2. For each rule:
  ##   a. Calculate intersections with cuboids in the list
  ##   b. Non-empty intersection -> add it to the list with an *inverted sign*
  ##     - e.g. "Undo" any previous rule for that region
  ##   c. "on" rule -> add cuboid to the list
  ## 3. Sum volumes of cuboids
  var l: seq[RebootStep]
  for s in steps:
    var new: seq[RebootStep]
    for s2 in l:
      let inter = intersection(s2.bounds, s.bounds)
      if inter.isSome():
        new.add((on: not s2.on, bounds: inter.unsafeGet()))
    if s.on:
      new.add(s)
    l.add(new)
  l.foldl(a + b.volume(), 0)

proc main() =
  const input = staticRead("../inputs/d22.txt")
  let steps = parseInput(input)

  echo "part 1: ", part1(steps)
  echo "part 2: ", part2(steps)

when isMainModule:
  when defined(testing):
    import unittest

    test "part 1":
      const input = staticRead("../inputs/d22.example.txt")
      let rebootSteps = parseInput(input)
      check part1(rebootSteps) == 590784

    test "part 2":
      const input = staticRead("../inputs/d22.example2.txt")
      let rebootSteps = parseInput(input)
      check part2(rebootSteps) == 2758514936282235

    test "slice intersection":
      check:
        intersection(0..5, 0..5) == some(0..5)
        intersection(0..5, 0..10) == some(0..5)
        intersection(0..5, 0..3) == some(0..3)
        intersection(0..5, 1..5) == some(1..5)
        intersection(1..5, 0..5) == some(1..5)
        intersection(0..5, 5..10) == some(5..5)
        intersection(0..5, 6..10).isNone()

    test "cuboid intersection":
      check:
        intersection(
          (lb: (0, 0, 0), ub: (10, 10, 10)),
          (lb: (0, 0, 0), ub: (10, 10, 10))
        ) == some((lb: (0, 0, 0), ub: (10, 10, 10)))
        intersection(
          (lb: (0, 0, 0), ub: (10, 10, 10)),
          (lb: (0, 0, 0), ub: (5, 10, 10))
        ) == some((lb: (0, 0, 0), ub: (5, 10, 10)))
        intersection(
          (lb: (0, 0, 0), ub: (10, 10, 10)),
          (lb: (0, 0, 0), ub: (5, 2, 10))
        ) == some((lb: (0, 0, 0), ub: (5, 2, 10)))
        intersection(
          (lb: (0, 0, 0), ub: (10, 10, 10)),
          (lb: (0, 0, 0), ub: (5, 2, 10))
        ) == some((lb: (0, 0, 0), ub: (5, 2, 10)))

  else:
    main()

