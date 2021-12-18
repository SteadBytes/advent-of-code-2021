import strscans

type
  Rectangle = tuple
    xMin: int
    xMax: int
    yMin: int
    yMax: int

func parseInput(s: string): Rectangle =
  let (ok, x1, x2, y1, y2) = s.scanTuple("target area: x=$i..$i, y=$i..$i")
  assert ok
  (x1, x2, y1, y2)

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
  let y = abs(target.yMin) - 1
  let yMax = y * (y + 1) div 2
  echo "part 1: ", yMax
  #echo "part 2: "

when isMainModule:
  when defined(testing):
    import unittest

    test "parseInput":
      check:
        parseInput("target area: x=20..30, y=-10..-5") == ((20, -10), (30, -5))
        parseInput("target area: x=282..314, y=-80..-45") == ((282, -80), (314, -45))

  else:
    main()

