import aoc
import strscans

type
  Rectangle = tuple
    xMin: int
    xMax: int
    yMin: int
    yMax: int

func contains(r: Rectangle, c: Coord): bool =
  c.x in r.xMin..r.xMax and c.y in r.yMin..r.yMax

func parseInput(s: string): Rectangle =
  let (ok, x1, x2, y1, y2) = s.scanTuple("target area: x=$i..$i, y=$i..$i")
  assert ok
  (x1, x2, y1, y2)

iterator probePath(velocity: Coord, target: Rectangle): Coord =
  ## Yield coordinates of the probe's path starting from `(0, 0)` until it
  ## passes `target`.
  var
    v = velocity
    loc = (0, 0)
  while loc.x <= target.xMax and loc.y >= target.yMin:
    yield loc
    loc = loc + v
    v = (max(0, v.x - 1), v.y - 1)


proc main() =
  const input = staticRead("../inputs/d17.txt")
  let target = parseInput(input)

  # From an initial positive vy, the probe will _always_ eventually return to
  # y=0 - coming down at the same velocity as it was launched up. The maximum
  # possible vy whilst hitting the target is therefore the y value of the
  # bottom of the target. Any more and the probe will undershoot the target.
  # At the step before returning to y=0 the probe will be travelling at
  # vy=vyMax - 1, the step before that vy=vyMax - 2, the step before that
  # vy=vyMax - 3 and so on. yMax is the sum of these velocities - given here by
  # a Gauss summation.
  let vyMax = abs(target.yMin) - 1
  let yMax = vyMax * (vyMax + 1) div 2
  echo "part 1: ", yMax

  # Straight forward search of possible initial velocities - simulating the
  # probe's path and recording whether it hits the target.  Due to similar
  # reasoning as for part 1, the search space can be constrained using the
  # coordinate ranges of the target as initial velocities outside of this range
  # will definitely not hit the target. Other than that, though, this is a
  # simple brute force search as I can't see any "trick" as in part 1.
  var hits = 0
  for vx in 0..target.xMax:
    for vy in target.yMin..vyMax:
      # Again, I wish Nim's iterators supported sequtils map/filter/any etc.
      for c in probePath((vx, vy), target):
        if target.contains(c):
          inc hits
          break

  echo "part 2: ", hits

when isMainModule:
  when defined(testing):
    import unittest

    test "parseInput":
      check:
        parseInput("target area: x=20..30, y=-10..-5") == ((20, -10), (30, -5))
        parseInput("target area: x=282..314, y=-80..-45") == ((282, -80), (314, -45))

  else:
    main()

