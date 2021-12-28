import aoc
import strutils, sequtils, sugar, sets

func parseInput(s: string): (seq[bool], HashSet[Coord]) =
  ## Note: Assumes well-formed input
  let sections = s.strip().split("\n\n")
  assert sections.len == 2
  # First line -> image enhancement algorithm (exactly 512 chars)
  let algo = sections[0].strip().mapIt(it == '#')
  assert algo.len == 512
  # 2D grid -> input image
  let lines = sections[1].strip().splitLines()
  let inputPixels = collect:
    for y, l in lines:
      for x, c in l:
        if c == '#': {(x, y)}
  (algo, inputPixels)

const window = [
  (-1, -1), (0, -1), (1, -1),
  (-1, 0), (0, 0), (1, 0),
  (-1, 1), (0, 1), (1, 1),
]

func enhance(
  litPixels: HashSet[Coord],
  algo: seq[bool],
  default: bool
): HashSet[Coord] =
  # Bounds of the currently "explored" portion of the grid
  let
    xs = litPixels.mapIt(it.x)
    ys = litPixels.mapIt(it.y)
    xMin = xs.min
    xMax = xs.max
    yMin = ys.min
    yMax = ys.max
  for y in yMin-1..<yMax+2:
    for x in xMin-1..<xMax+2:
      let c = (x, y)
      let x =
        window.map(v => c + v).map(
          c => int(
            if xMin <= c.x and c.x <= xMax and yMin <= c.y and c.y <= yMax:
              # Within explored region -> use known value
              litPixels.contains(c)
            else:
              # Outside explored region -> use default value for the rest of
              # the grid
              default
          )
        )
        .foldl((a * 2) + b)
      if algo[x]:
        result.incl(c)

func findLitPixels(algo: seq[bool], inPixels: HashSet[Coord],
    rounds: int): int =
  ## If the first pixel of the enhancement algorithm is list and the last pixel
  ## is off, *every* pixel in the infinite grid will be lit by the first round
  ## of enhancement, then unlit by the next, then lit by the next and so on: -
  ## - All of these pixels begin unlit
  ## - On the first round, the 3x3 window binary number for each such pixel
  ##   will be 0
  ## - All pixels replaced with enhancement[0] - switching them to lit
  ## - On the second round, the 3x3 window binary number will be 512
  ## - All pixels replaced with enhancement[512] - switching them off
  ## - Repeat ad infinitum
  ##
  ## To accomodate for this, `enhance` takes a `default` parameter to indicate
  ## the value to be used for pixels outside of the "explored" portion of the
  ## infinite grid.
  ##
  ## Note: This behaviour is _not_ demonstrated in the puzzle example input.
  (0..<rounds).foldl(
    enhance(
      a,
      algo,
      bool(b and 1) and algo[0]
  ),
    inPixels
  ).len

func part1(algo: seq[bool], inPixels: HashSet[Coord]): int =
  findLitPixels(algo, inPixels, 2)

func part2(algo: seq[bool], inPixels: HashSet[Coord]): int =
  findLitPixels(algo, inPixels, 50)

proc main() =
  const input = staticRead("../inputs/d20.txt")
  let (algo, inPixels) = parseInput(input)
  echo "part 1: ", part1(algo, inPixels)
  echo "part 2: ", part2(algo, inPixels)

when isMainModule:
  when defined(testing):
    import unittest

    const exampleInput = staticRead("../inputs/d20.example.txt")
    let (algo, inPixels) = parseInput(exampleInput)
    test "part 1":
      check part1(algo, inPixels) == 35

    test "part 2":
      check part2(algo, inPixels) == 3351

  else:
    main()

